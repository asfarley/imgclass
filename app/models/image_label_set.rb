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

  def percent_remaining
    num_unlabeled = image_labels.where(:label_id => nil).count
    if(images.count > 0)
      percent_remaining = 100 * num_unlabeled / images.count
    else
      percent_remaining = 0
    end
  end

  def isComplete?
    (percent_remaining == 0) && (image_labels.count >= images.count)
  end

  def fileLabelPairs
    images.map{ |image| { "url" => File.basename(image.url), "label" => image.most_likely_label_text  } }
  end

  def fileVectorPairs
    images.map{ |image| { "url" => File.basename(image.url), "vector" => image.most_likely_label_onehot  } }
  end

  def fileLabelVectorTriples
    images.map{ |image| { "url" => File.basename(image.url), "label" => image.most_likely_label_text, "vector" => image.most_likely_label_onehot  } }
  end

  def generateLabelsTextfile
    downloadString = label_set.textfileHeader + "\r\n"
    downloadString += fileLabelVectorTriples.inject("") {|textfileString,fileLabelVectorTriple| textfileString + "\"" + fileLabelVectorTriple["url"] + "\" " + fileLabelVectorTriple["label"] + " " + fileLabelVectorTriple["vector"] + "\r\n"}
    labelsPath = "/tmp/labels.txt"
    File.open(labelsPath, 'w+') {|f| f.write(downloadString) }
    return labelsPath
  end

end
