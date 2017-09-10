## The Image class represents the input image for each single element in a training set.

class Image < ActiveRecord::Base
  #mount_uploader :url, ImageUploader
  belongs_to :image_label_set
  has_many :image_labels

  def count_labels(label)
      ImageLabel.where("image_id = ? and label_id = ?", self.id, label.id).count
  end

  # Attempt to determine the most-likely correct label/ground-truth for a
  # particular image despite potentially conflicting labels.
  #
  # This method takes the most-frequently selected label as the ground truth.
  # This method returns a human-readable string to identify the
  # image ground-truth class.
  def most_likely_label_text
    labels = ImageLabel.where("image_id = ?", self.id).map{ |il| il.label }
    freq = labels.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    most_likely = labels.max_by { |v| freq[v] }
    most_likely.nil? ? "Unknown" : most_likely.text
  end

  def most_likely_bounding_boxes
    targets = ImageLabel.where("image_id = ?", self.id).map{ |il| il.target }
    #TODO: Replace below calculation with something similar for bounding boxes
    #freq = labels.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    most_likely = targets[0]
    most_likely.nil? ? "Unknown" : most_likely
  end


  # Attempt to determine the most-likely correct label/ground-truth for a
  # particular image despite potentially conflicting labels.
  #
  # This method takes the most-frequently selected label as the ground truth.
  # This method returns a one-hot vector (array) correponding to the image ground-truth
  # class.
  def most_likely_label_onehot
    labels = ImageLabel.where("image_id = ?", self.id).map{ |il| il.label }
    freq = labels.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    most_likely = labels.max_by { |v| freq[v] }
    most_likely.nil? ? "Unknown" : most_likely.getOneHotVector
  end

  before_destroy {|image|
    image.image_labels.destroy_all
  }

end
