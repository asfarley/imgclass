class Label < ActiveRecord::Base
  belongs_to :label_set

  def getOneHotVector
    vector = label_set.labels.inject("[") { |vec, l| vec + (vec == "[" ? "" : " ") + (l == self ? "1" : "0") } + "]"
  end

end
