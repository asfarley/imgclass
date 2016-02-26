class LabelSet < ActiveRecord::Base
  has_many :labels
  has_one :image_label_set

  def textfileHeader
    raw_header = labels.inject("") { |header, l| header + " " + l.text}
    header = "Classes: " + raw_header
  end
end
