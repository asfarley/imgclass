## The ImageLabel class represents a single user-identified answer
# for a single image in a training set.
#
# Multiple ImageLabels may be associated with one image, in order to provide
# redundant labeling. ImageLabels may consist of discrete class vectors
# (one-hot vector output) or a more generic string representation
# capable of storing bounding-box lists.

class ImageLabel < ApplicationRecord
  belongs_to :image
  belongs_to :label
  belongs_to :user
  belongs_to :job
  has_one :image_label_set, through: :image

  #Return other labels for the same image.
  #Used to compare the degree of similarity between different user's responses.
  def competing_image_labels
    return image.image_labels.select{ |il| (not il.target.nil?) && (not il == self) }
  end

  def to_object_count_hashG
    count_hash = {}
    if(target.nil? or target == "")
      return {}
    end
    begin
      json = JSON.parse(target)
      json.each do |bounding_box|
        if count_hash.key? bounding_box["classname"]
          count_hash[bounding_box["classname"]] = count_hash[bounding_box["classname"]] + 1
        else
          count_hash[bounding_box["classname"]] = 1
        end
      end
    rescue Exception => ex
      debugger.log "Exception in JSON object-count parsing: #{ex}"
    end
    return count_hash
  end

  def competing_object_count_hashes
    cil = competing_image_labels
    ch = cil.map { |image_label| image_label.to_object_count_hash}
    return ch
  end

  def match(object_count_hash_1, object_count_hash_2)
    elementwise_difference = {}
    keys = object_count_hash_1.keys + object_count_hash_2.keys
    keys.each do |key|
      diff = 1
      max = 1
      if (object_count_hash_1.key?(key) && object_count_hash_2.key?(key))
        diff = (object_count_hash_1[key] - object_count_hash_2[key]).abs
        max = [object_count_hash_1[key], object_count_hash_2[key]].max
      elsif (object_count_hash_1.key? key)
        diff = 1
        max = 1
      elsif (object_count_hash_2.key? key)
        diff = 1
        max = 1
      end
      match_percent = 100.0*(max - diff)/max
      elementwise_difference[key] = match_percent
    end
    return elementwise_difference
  end

  def match_against_competing_image_labels
    ch = competing_object_count_hashes
    difference_hashes = []
    och = to_object_count_hash()
    ch.each do |competing_hash|
      diff = match(och, competing_hash)
      difference_hashes.push(diff)
    end
    return difference_hashes
  end

  def single_measure_agreement_against_competing_labels
    match_hashes = match_against_competing_image_labels()
    if(match_hashes.count < 1)
      return 100.0
    end
    match_percents = match_hashes.map{ |match_hash|
      match_on_each_class = match_hash.values
      numerator = match_on_each_class.reduce(:+)
      denominator = match_on_each_class.size.to_f
      if(numerator == nil || denominator == nil || denominator == 0)
        return 0.0
      end
      return match_on_each_class.reduce(:+) / match_on_each_class.size.to_f
    }
    average = match_percents.reduce(:+) / match_percents.size.to_f
  end

end
