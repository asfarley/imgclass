class LabelSet < ActiveRecord::Base
  has_many :labels
  has_one :image_label_set
end
