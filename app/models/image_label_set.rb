class ImageLabelSet < ActiveRecord::Base
  belongs_to :image_set
  belongs_to :label_set
  belongs_to :user
  has_many :jobs
end
