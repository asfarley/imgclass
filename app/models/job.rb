class Job < ActiveRecord::Base
  belongs_to :image_label_set
  belongs_to :user
end
