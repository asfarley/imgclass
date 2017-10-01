## The Label class represents each individual class which may be present in
# a particular training set. For example, a single label might be "Car".

class Label < ApplicationRecord
  belongs_to :image_label_set

  # Generate the one-hot vector (all elements zero except for the target class)
  # which represents this label.
  def getOneHotVector
    vector = image_label_set.labels.inject("[") { |vec, l| vec + (vec == "[" ? "" : " ") + (l == self ? "1" : "0") } + "]"
  end

end
