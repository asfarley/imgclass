## The ImageLabelSet is the primary, top-most class managing an entire training image set
# along with labels/user responses.
# ImageLabelSets may contain redundant labelling of inidividual training set images
# in order to evaluate the agreement between different users' responses.
#
# If redundant labels are present (multiple user responses for a single image), this class
# provides the functionality for flagging incorrectly-labelled images and for determining
# the most-likely label for a particular image in the case of conflicting labels.

class ImageLabelSet < ActiveRecord::Base
  require 'fileutils'
  belongs_to :user
  has_many :jobs
  has_many :images
  has_many :labels
  has_many :image_labels, through: :images

  before_destroy {|ils|
    FileUtils.rm_rf("/srv/imgclass/public/images/#{ils.id}")
    ils.images.destroy_all
    ils.labels.destroy_all
    ils.image_labels.destroy_all
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
    if bounding_box_mode
      downloadString += fileTargetBoundingBoxes.inject("") {|textfileString,targetBoundingBox| textfileString + "\"" + targetBoundingBox["url"] + "\" " + targetBoundingBox["target"] + "\n"}
    else
      downloadString += textfileHeader + "\r\n"
      downloadString += fileLabelVectorTriples.inject("") {|textfileString,fileLabelVectorTriple| textfileString + "\"" + fileLabelVectorTriple["url"] + "\" " + fileLabelVectorTriple["label"] + " " + fileLabelVectorTriple["vector"] + "\n"}
    end
    labelsPath = File.join(Rails.root, "tmp", "labels.txt")
    File.open(labelsPath, 'w+') {|f| f.write(downloadString) }
    return labelsPath
  end

  def generateYoloTrainingFiles
    #Delete old output folder if it exists
    output_path = File.join(Rails.root, "tmp", "yolo_set")
    FileUtils.rm_rf(output_path) if (File.exist?(output_path) && File.directory?(output_path))
    Dir.mkdir(output_path)#Create temporary output folder
    images.each do |image| #For each image
      image_path = File.join(Rails.root, "public", image.url)
      this_image_label = image.most_likely_bounding_boxes
      basename = File.basename(image.url, ".*")
      basename_with_ext = File.basename(image.url)
      this_image_subfolder = File.join(output_path, basename)
      Dir.mkdir(this_image_subfolder) # Create folder
      #this_image_path = File.join(this_image_subfolder, basename_with_ext)
      FileUtils.cp(image_path,this_image_subfolder) #Copy image
      # Create textfile
      this_image_label_path = File.join(this_image_subfolder, basename + ".txt")
      File.write(this_image_label_path, toYoloFormat(this_image_label))
    end
    return output_path
  end

  def toYoloFormat(image_label_json)
    yolo_format_string = ""
    image_label_hashes = JSON.parse(image_label_json)
    image_label_hashes.each do |bb_json|
      class_int = classStringToInt(bb_json["classname"])
      left = bb_json["x"].to_f.round(4)
      top = bb_json["y"].to_f.round(4)
      right = (left + bb_json["width"].to_f).round(4)
      bottom = (top + bb_json["height"].to_f).round(4)
      yolo_format_string += "#{class_int} #{left} #{top} #{right} #{bottom}\n"
    end
    return yolo_format_string
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
  #
  # This method should not be necessary - image labels should only
  # be created upon job creation.
  def remainingImageLabels
    image_labels.select{ |il| il.job.nil? }
  end

  # Return a subset of image-labels which have not yet been
  # assigned to a job, up to a maximum number.
  #
  # This method may be obsolete - review whether it's actually called
  # at any point.
  def batchOfRemainingLabels(max)
    rem = remainingImageLabels
    rem[0..max]
  end

  def labelledImagesCount
    labelledImages = image_labels.select{ |il| ! (il.label.nil? and il.target.nil?) }
    return labelledImages.count
  end

end