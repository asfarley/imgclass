class ImageLabelSet < ActiveRecord::Base

  require 'image_file_utils'
  include ImageFileUtils

  belongs_to :image_set
  belongs_to :label_set
  belongs_to :user
  has_many :jobs
  has_many :images, through: :image_set
  has_many :labels, through: :label_set
  has_many :images, through: :image_set
  has_many :image_labels, through: :images

  before_destroy {|ils|
    # ER TODO: verify if it works
    imageDir = ImageFileUtils.dir_for_set(ils.image_set_id)
    FileUtils.rm_rf(imageDir)
    ImageSet.find(ils.image_set_id).images.destroy_all
    ImageSet.find(ils.image_set_id).destroy
    LabelSet.find(ils.label_set_id).labels.destroy_all
    LabelSet.find(ils.label_set_id).destroy
  }

  def percent_remaining
    num_unlabeled = image_labels.where(:label_id => nil).count
    if(images.count > 0)
      percent_remaining = 100.0 * num_unlabeled.to_f / images.count
    else
      percent_remaining = 0.0
    end
  end

  def percentAssigned
    totalImages = image_labels.count
    assignedImages = image_labels.select{ |il| ! il.job.nil? }
    pct = (assignedImages.count.to_f/totalImages)*100.0
    pct.round(1)
  end

  def percentComplete
    totalImages = image_labels.count
    labelledImages = image_labels.select{ |il| ! il.label.nil? }
    pct = (labelledImages.count.to_f/totalImages)*100.0
    pct.round(1)
  end

  def numImagesRemaining
    num_remaining = image_labels.count - image_labels.select{ |il| ! il.label.nil? }.count
  end

  def isComplete?
    (percent_remaining == 0) && (image_labels.count >= images.count)
  end

  def fileLabelPairs
    images.map{ |image| { "url" => image.filename, "label" => image.most_likely_label_text  } }
  end

  def fileVectorPairs
    images.map{ |image| { "url" => image.filename, "vector" => image.most_likely_label_onehot  } }
  end

  def fileLabelVectorTriples
    images.map{ |image| { "url" => image.filename, "label" => image.most_likely_label_text, "vector" => image.most_likely_label_onehot  } }
  end

  def generateLabelsTextfile
    downloadString = label_set.textfileHeader + "\r\n"
    downloadString += fileLabelVectorTriples.inject("") {|textfileString,fileLabelVectorTriple| textfileString + "\"" + fileLabelVectorTriple["url"] + "\" " + fileLabelVectorTriple["label"] + " " + fileLabelVectorTriple["vector"] + "\r\n"}
    labelsPath = "/tmp/labels.txt"
    File.open(labelsPath, 'w+') {|f| f.write(downloadString) }
    return labelsPath
  end

  def remainingImageLabels
    image_labels.select{ |il| il.job.nil? }
  end

  def batchOfRemainingLabels(max)
    rem = remainingImageLabels
    rem[0..max]
  end

end
