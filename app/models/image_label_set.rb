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
  belongs_to :image_set
  belongs_to :label_set
  belongs_to :user
  has_many :jobs
  has_many :images, through: :image_set
  has_many :labels, through: :label_set
  has_many :images, through: :image_set
  has_many :image_labels, through: :images

  before_destroy {|ils|
    FileUtils.rm_rf("/srv/imgclass/public/images/#{ils.image_set_id}")
    ImageSet.find(ils.image_set_id).images.destroy_all
    ImageSet.find(ils.image_set_id).destroy
    LabelSet.find(ils.label_set_id).labels.destroy_all
    LabelSet.find(ils.label_set_id).destroy
  }

  # Determine the percentage of unclassified images in this training set.
  def percent_remaining
    num_unlabeled = image_labels.where(:label_id => nil).count
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
    labelledImages = image_labels.select{ |il| ! il.label.nil? }
    pct = (labelledImages.count.to_f/totalImages)*100.0
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

  # Generate labels.txt file containing user class responses (ground truth) for a particular ImageLabelSet.
  def generateLabelsTextfile
    downloadString = label_set.textfileHeader + "\r\n"
    downloadString += fileLabelVectorTriples.inject("") {|textfileString,fileLabelVectorTriple| textfileString + "\"" + fileLabelVectorTriple["url"] + "\" " + fileLabelVectorTriple["label"] + " " + fileLabelVectorTriple["vector"] + "\r\n"}
    labelsPath = File.join(Rails.root, "tmp", "labels.txt")
    File.open(labelsPath, 'w+') {|f| f.write(downloadString) }
    return labelsPath
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

end
