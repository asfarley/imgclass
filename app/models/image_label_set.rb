## The ImageLabelSet is the primary, top-most class managing an entire training image set
# along with labels/user responses.
# ImageLabelSets may contain redundant labelling of inidividual training set images
# in order to evaluate the agreement between different users' responses.
#
# If redundant labels are present (multiple user responses for a single image), this class
# provides the functionality for flagging incorrectly-labelled images and for determining
# the most-likely label for a particular image in the case of conflicting labels.

class ImageLabelSet < ApplicationRecord
  require 'fileutils'
  require 'open-uri'
  require 'parallel'
  require 'zip'
  require './app/lib/zipfilegenerator'
  require './app/lib/yolofilegenerator'
  belongs_to :user
  has_many :jobs
  has_many :images
  has_many :labels
  has_many :image_labels, through: :images

  before_destroy {|ils|
    FileUtils.rm_rf("/srv/imgclass/public/images/#{ils.id}")
    ImageLabelSet.transaction do
      ils.images.destroy_all
      ils.labels.destroy_all
      ils.image_labels.destroy_all
      ils.jobs.destroy_all
    end
  }

  # Determine the percentage of unclassified images in this training set.
  def percent_remaining
    #num_unlabeled = image_labels.where(:label_id => nil).count
    num_unlabeled = image_labels.count - labelledImagesCount()
    if(images.count > 0)
      percent_remaining = 100.0 * num_unlabeled.to_f / images.count
    else
      percent_remaining = 0.0
    end
  end

  # Determine the percentage of assigned images in this training set.
  def percentAssigned
    totalImages = image_labels.count
    assignedImages = image_labels.select{ |il| ! il.job.nil? }
    pct = (assignedImages.count.to_f/totalImages)*100.0
    pct.round(1)
  end

  # Determine the percentage of images which have been classified by users.
  def percentComplete
    totalImages = image_labels.count
    pct = (labelledImagesCount()/totalImages)*100.0
    pct.round(1)
  end

  # Calculate to total number of unclassified images remaining in this training set.
  def numImagesRemaining
    num_remaining = image_labels.count - image_labels.select{ |il| ! il.label.nil? }.count
  end

  def numImageLabelsRemaining
    image_labels.select{ |il| il.target.nil? }.count
  end

  # Determine whether all training images in this set have been classified.
  def isComplete?
    (percent_remaining == 0) && (image_labels.count >= images.count)
  end

  # Generate a list of pairs mapping files to most-likely ground truth classes in human-readable string format.
  def fileLabelPairs
    images.map{ |image| { "url" => File.basename(image.url), "label" => image.most_likely_label_text  } }
  end

  # Generate a list of pairs mapping files to most-likely ground truth classes in one-hot vector format.
  def fileVectorPairs
    images.map{ |image| { "url" => File.basename(image.url), "vector" => image.most_likely_label_onehot  } }
  end

  # Generate a list of triples mapping files to most-likely ground truth classes in human-readable and one-hot vector format.
  def fileLabelVectorTriples
    images.map{ |image| { "url" => File.basename(image.url), "label" => image.most_likely_label_text, "vector" => image.most_likely_label_onehot  } }
  end

  def fileTargetBoundingBoxes
    images.map{ |image| {"url" => File.basename(image.url), "target" => image.most_likely_bounding_boxes} }
  end

  # Generate labels.txt file containing user class responses (ground truth) for a particular ImageLabelSet.
  def generateLabelsTextfile
    downloadString = ""
    downloadString += fileTargetBoundingBoxes.inject("") {|textfileString,targetBoundingBox| textfileString + "\"" + targetBoundingBox["url"] + "\" " + targetBoundingBox["target"] + "\n"}
    labelsPath = File.join(Rails.root, "tmp", "labels.txt")
    File.open(labelsPath, 'w+') {|f| f.write(downloadString) }
    return labelsPath
  end

  def generateYoloTrainingFiles
    #Delete old output folder if it exists
    output_path = File.join(Rails.root, "tmp", "yolo_set")
    logger.debug("Removing old output folder if it exists...")
    if (File.exist?(output_path) && File.directory?(output_path))
      logger.debug("Old folder found, rm_rf called...")
      result = FileUtils.rm_rf(output_path, :verbose => true)
      logger.debug("rm_rf result: #{result}")
    end
    logger.debug("Creating new output folder")
    Dir.mkdir(output_path)#Create temporary output folder
    #Create Yolo configuration files
    images.each do |image| #For each image
      basename = File.basename(image.url, ".*")
      basename_with_ext = File.basename(image.url)
      this_image_subfolder = File.join(output_path, basename)
      Dir.mkdir(this_image_subfolder) # Create folder

      if (image.url.include? "http")
        downloadImageToPath(image.url,File.join(this_image_subfolder,basename_with_ext))
      else
        image_path = File.join(Rails.root, "public", image.url)
        FileUtils.cp(image_path,this_image_subfolder) #Copy image
      end

      # Create textfile
      this_image_label_path = File.join(this_image_subfolder, basename + ".txt")
      this_image_label = image.most_likely_bounding_boxes
      File.open(this_image_label_path, 'w') do |f|
        f.write(toYoloFormat(this_image_label))
      end
    end
    return output_path
  end

  def toYoloFormat(image_label_json)
    begin
      yolo_format_string = ""
      image_label_hashes = JSON.parse(image_label_json)
      image_label_hashes.each do |bb_json|
        class_int = classStringToInt(bb_json["classname"])
        left = bb_json["x"].to_f.round(4)
        top = bb_json["y"].to_f.round(4)
        x_center = left + (bb_json["width"].to_f / 2)
        y_center = top + (bb_json["height"].to_f / 2)
        #right = (left + bb_json["width"].to_f).round(4)
        #bottom = (top + bb_json["height"].to_f).round(4)
        yolo_format_string += "#{class_int} #{x_center} #{y_center} #{bb_json["width"].to_f.round(4)} #{bb_json["height"].to_f}\n"
      end
      return yolo_format_string
    rescue Exception => ex
      return ""
    end
  end

  def classStringToInt(class_string)
    class_list = labels.map{ |l| l.text }
    int = class_list.find_index(class_string)
  end

  # Generate the header (first line) of a textfile containing
  # ground-truth answers for an image set. The purpose of the first line
  # is to provide human-readable string mappings to the one-hot output
  # vector format in labels.txt.
  def textfileHeader
    raw_header = labels.inject("") { |header, l| header + " " + l.text}
    header = "Classes: " + raw_header
  end

  # Return a list of image labels which haven't been assigned to a job.
  def remainingImageLabels
    image_labels.eager_load(:job).select{ |il| il.job.nil? }
  end

  def unassignedImages
    images.eager_load(:image_labels).select{ |im| im.image_labels.nil? || im.image_labels.size == 0 }
  end

  # Return a subset of image-labels which have not yet been
  # assigned to a job, up to a maximum number.
  def batchOfRemainingLabels(max, job_id)
    rem = unassignedImages()
    if(rem.count == 0)
      rem = images.eager_load(:image_labels).sort_by{ |image| image.image_labels.size }
    end
    remaining_selected = rem[0...max]
    ImageLabel.transaction do
      remaining_selected.each do |image|
        il = ImageLabel.new()
        il.image = image
        il.job_id = job_id
        il.save
      end
    end
    return remaining_selected
  end

  def labelledImagesCount
    labelledImages = image_labels.select{ |il| ! (il.label.nil? and il.target.nil?) }
    return labelledImages.count
  end

  def downloadImageToPath(url,path)
    path_filtered = path.delete("\n")
    if(url[-1] == "\n")
      url.chop!
    end
    uri = URI.parse(URI.encode(url))
    nAttempts = 0
    succeeded = false
    while (nAttempts < 5 && succeeded == false) do
      begin
        open(path_filtered, 'wb') do |file|
          file << open(uri, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
        end
        succeeded = true
      rescue
        nAttempts = nAttempts + 1
        succeeded = false
      end
    end
  end

  def assignmentCoverageBinaryVector
    #For each image, map to a boolean: has this image been assigned in a job?
    images.eager_load(:image_labels).map { |image| image.image_labels.size }
  end

  def completionCoverageBinaryVector
    #For each images, map to a boolean: has this image been labelled?
    images.eager_load(:image_labels).map { |image|
      (image.image_labels.select{ |il| (il.target.nil?) }.count == 0) && (image.image_labels.size != 0)
    }
  end

  def assign_entire_set
    workers = User.all.select{ |user| user.is_active_worker}
    #Calculate number of jobs to create for a full assignment
    total_assignment_count = images.count.to_f
    ImageLabel.transaction do
      images.each_slice(Job::MAX_JOB_SIZE) do |images_slice|
        worker = workers.sample
        j = Job.new()
        j.image_label_set_id = id
        j.user_id = worker.id
        j.save
        images_slice.each do |image|
          il = ImageLabel.new
          il.image_id = image.id
          il.job_id = j.id
          il.user_id = worker.id
          il.save
        end
      end
    end
  end

  def assign_remaining
    workers = User.all.select{ |user| user.is_active_worker}
    #Calculate number of jobs to create for a full assignment
    total_assignment_count = unassignedImages().count.to_f
    ImageLabel.transaction do
      unassignedImages().each_slice(Job::MAX_JOB_SIZE) do |images_slice|
        worker = workers.sample
        j = Job.new()
        j.image_label_set_id = id
        j.user_id = worker.id
        j.save
        images_slice.each do |image|
          il = ImageLabel.new
          il.image_id = image.id
          il.job_id = j.id
          il.user_id = worker.id
          il.save
        end
      end
    end
  end

  # Debug-only.
  # This method is intended to give a blank
  # target to each image/image_label in the set.
  # This is used to quickly give labels to the set, so it can be
  # downloaded.
  def label_with_blanks
    ImageLabel.transaction do
      image_labels.each do |il|
        il.target = "[]";
        il.save
      end
    end
  end

  def download_folder_path
    return File.join(Rails.root, "tmp", "ImageLabelSet_#{id}")
  end

  # In parallel for each image in this set,
  # a) create a folder for this image
  # b) download the image
  # c) write the most-likely bounding box tags to the folder containing the image
  def parallel_download(urls_targets_hash_list, storage_path)
    preexisting_folders = Dir.entries(storage_path)
    logger.debug "Before parallel_download, folders exist: #{preexisting_folders}"
    Parallel.each(urls_targets_hash_list, in_threads: 32) {|url_target_pair|
      # Download image
      basename = File.basename(url_target_pair[:url], ".*")
      basename_with_ext = File.basename(url_target_pair[:url])
      this_image_subfolder = File.join(storage_path, basename)
      logger.debug "Making directory: #{this_image_subfolder}"
      if (File.exist? this_image_subfolder)
        FileUtils.rm_rf(this_image_subfolder)
      end
      Dir.mkdir(this_image_subfolder) # Create folder
      path = File.join(this_image_subfolder, basename_with_ext)
      downloadImageToPath(url_target_pair[:url], path)
      # Create textfile
      this_image_label_path = File.join(this_image_subfolder, basename + ".txt")
      this_image_label = url_target_pair[:target]
      File.open(this_image_label_path, 'w') do |f|
        f.write(toYoloFormat(this_image_label))
      end
    }
  end

  def generate_output_folder_if_complete
    t1 = Time.now
    # If output folder already exists, delete it
    output_path = download_folder_path()
    if (File.exist?(output_path) && File.directory?(output_path))
      logger.debug "Zipped output path exists, deleting..."
      result = FileUtils.rm_rf(output_path)
      logger.debug "Result of deletion: #{result}"
    end
    FileUtils::mkdir_p(output_path)
    preexisting_folders = Dir.entries(output_path)
    logger.debug "In generate_output_folder_if_complete, folders exist: #{preexisting_folders}"
    #Zip urls with most likely bounding boxes
    begin
      logger.debug "Calculating most-likely targets..."
      urls_targets_hash_list = images.eager_load(:image_labels).select{ |image| image.is_labelled}.map{ |image| {:url => image.url, :target => image.most_likely_bounding_boxes} };nil
    rescue Exception => ex
      logger.debug "Most-likely target calculation failed: #{ex}"
    end
    logger.debug "Downloading #{urls_targets_hash_list.count} images..."
    begin
      parallel_download(urls_targets_hash_list, output_path);nil
    rescue Exception => ex
      logger.debug "Parallel image download failed: #{ex}"
    end
    logger.debug "Generating Yolo CFG files..."
    image_file_paths = images.map{ |i| i.url }
    names_list = labels.map { |l| l.text }
    YoloFileGenerator.generate_all_yolo_training_files(output_path, image_file_paths, names_list)
    zipfile_name = File.join(Rails.root, "tmp", "ImageLabelSet_#{id}.zip")
    logger.debug "Removing stale zipfile..."
    removal_result = FileUtils.rm_rf(zipfile_name)
    logger.debug "Stale zipfile delete result: #{removal_result}"
    zf = ZipFileGenerator.new(output_path, zipfile_name);nil
    logger.debug "Zipping folder (#{zipfile_name})..."
    zip_result = zf.write();nil
    logger.debug "Zip result: #{zip_result}"
    logger.debug "Removing unzipped folder..."
    unzipped_delete_result = FileUtils.rm_rf(output_path)
    logger.debug "Unzipped delete result: #{unzipped_delete_result}"
    logger.debug "Done."
    t2 = Time.now
    delta = t2 - t1
    logger.debug "generate_output_folder_if_complete took #{delta} seconds"
  end

  def zipped_output_folder_name
    return File.join(Rails.root, "tmp", "ImageLabelSet_#{id}.zip")
  end

  def zipped_output_folder_exists
    return (File.exist?(zipped_output_folder_name()))
  end

  def path_safe_name
    name.gsub /[^a-z0-9\-]+/i, '_'
  end

end
