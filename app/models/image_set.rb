class ImageSet < ActiveRecord::Base
  has_many :images
  has_one :image_label_set
end
