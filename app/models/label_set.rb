## The labelSet class represents a collection of unique labels which may be
# applied to each image in the associated ImageLabelSet. For instance,
# one LabelSet may contain:
# (Car, Truck, Bus, Person, Bicycle, Motorcycle)

class LabelSet < ActiveRecord::Base
  has_many :labels
  has_one :image_label_set

  # Generate the header (first line) of a textfile containing
  # ground-truth answers for an image set. The purpose of the first line
  # is to provide human-readable string mappings to the one-hot output
  # vector format in labels.txt.
  def textfileHeader
    raw_header = labels.inject("") { |header, l| header + " " + l.text}
    header = "Classes: " + raw_header
  end
end
