## The ImageLabel class represents a single user-identified answer
# for a single image in a training set.
#
# Multiple ImageLabels may be associated with one image, in order to provide
# redundant labeling. ImageLabels may consist of discrete class vectors
# (one-hot vector output) or a more generic string representation
# capable of storing bounding-box lists.

class ImageLabel < ActiveRecord::Base
  belongs_to :image
  belongs_to :label
  belongs_to :user
  belongs_to :job
  belongs_to :image_label_set
end
