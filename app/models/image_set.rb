## An image set represents a collection of images (without associated targets or answers) for a particular
# ImageLabelSet.

class ImageSet < ActiveRecord::Base
  has_many :images
  has_one :image_label_set
end
