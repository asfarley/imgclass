## The ImageLabel class represents a single answer for a training image.
# Right now, ImageLabel objects can only represent a single-class label.
# Soon, this class will be extended to allow for (multiple) bounding box labels per image.

class ImageLabel < ActiveRecord::Base
  belongs_to :image
  belongs_to :label
  belongs_to :user
  belongs_to :job
end
