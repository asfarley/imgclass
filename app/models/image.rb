class Image < ActiveRecord::Base
  require 'image_file_utils'
  include ImageFileUtils

  belongs_to :image_set
  has_many :image_labels

  def count_labels(label)
      ImageLabel.where("image_id = ? and label_id = ?", self.id, label.id).count
  end

  def most_likely_label_text
    labels = ImageLabel.where("image_id = ?", self.id).map{ |il| il.label }
    freq = labels.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    most_likely = labels.max_by { |v| freq[v] }
    most_likely.nil? ? "Unknown" : most_likely.text
  end

  def most_likely_label_onehot
    labels = ImageLabel.where("image_id = ?", self.id).map{ |il| il.label }
    freq = labels.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    most_likely = labels.max_by { |v| freq[v] }
    most_likely.nil? ? "Unknown" : most_likely.getOneHotVector
  end

  # virtual path for the image. Calculated based on the site settings and image set id
  def vpath
    vdir_for_set(image_set_id) + filename
  end

  before_destroy {|image|
    image.image_labels.destroy_all
  }

end
