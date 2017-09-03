## The labelSet class represents a collection of unique labels which may be
# applied to each image in the associated ImageLabelSet. For instance,
# one LabelSet may contain:
# (Car, Truck, Bus, Person, Bicycle, Motorcycle)

class LabelSet < ActiveRecord::Base
  has_many :labels
  has_one :image_label_set

  def textfileHeader
    raw_header = labels.inject("") { |header, l| header + " " + l.text}
    header = "Classes: " + raw_header
  end
end
