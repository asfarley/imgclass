class ImageLabel < ApplicationRecord
  belongs_to :label
  belongs_to :image
  belongs_to :user
  belongs_to :job
end
