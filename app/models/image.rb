## The Image class represents the input image for each single element in a training set.

class Image < ApplicationRecord
  #mount_uploader :url, ImageUploader
  belongs_to :image_label_set
  has_many :image_labels

  def count_labels(label)
      ImageLabel.where("image_id = ? and label_id = ?", self.id, label.id).count
  end

  # Attempt to determine the most-likely correct label/ground-truth for a
  # particular image despite potentially conflicting labels.
  #
  # This method takes the most-frequently selected label as the ground truth.
  # This method returns a human-readable string to identify the
  # image ground-truth class.
  def most_likely_label_text
    labels = ImageLabel.where("image_id = ?", self.id).map{ |il| il.label }
    freq = labels.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    most_likely = labels.max_by { |v| freq[v] }
    most_likely.nil? ? "Unknown" : most_likely.text
  end

  # Select the best apparent choice from
  # competing ImageLabels.
  # The best choice is identified by counting
  # the number of objects in each competing
  # ImageLabel and selecting the ImageLabel
  # closest to the average.
  # A simple form of outlier rejection.
  def most_likely_bounding_boxes
    targets = image_labels.map{ |il| il.target }
    #1. Calculate the number of objects of each type, in each target JSON object
    counts_hashes = all_targets_count_hash_padded()

    #2. Calculate the average number of object of each type in targets
    averages = average_counts_hash()

    #3. Compare each target against the average count
    absolute_difference_hashes = counts_hashes.map{ |counts_hash| absolute_difference_count_hashes(counts_hash, averages) }
    absolute_diff_sum_hashes = absolute_difference_hashes.map{ |absolute_diff_hash| absolute_diff_hash.values.sum }

    #4. Select the target nearest to the average
    most_likely = targets[absolute_diff_sum_hashes.index(absolute_diff_sum_hashes.min)]
    most_likely.nil? ? "[]" : most_likely
  end


  # Attempt to determine the most-likely correct label/ground-truth for a
  # particular image despite potentially conflicting labels.
  #
  # This method takes the most-frequently selected label as the ground truth.
  # This method returns a one-hot vector (array) correponding to the image ground-truth
  # class.
  def most_likely_label_onehot
    labels = ImageLabel.where("image_id = ?", self.id).map{ |il| il.label }
    freq = labels.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    most_likely = labels.max_by { |v| freq[v] }
    most_likely.nil? ? "Unknown" : most_likely.getOneHotVector
  end

  # Map each of this image's associated ImageLabels to a hash
  # corresponding to the ImageLabel's count of each object type identified.
  def all_targets_count_hash
    counts_hash_list = image_labels.map{ |il| target_to_count_hash(il.target) }
    return counts_hash_list
  end

  # The "target" datatype (string) actually corresponds more closely to the ImageLabel class
  # but it's used here, so it's defined here.
  # The "target" property is a JSON string representation of a list of object bounding-boxes.
  # Each bounding box includes:
  # x,y,width,height,classname
  # where x,y,width and height are relative coordinates (0 to 1 in each dimension).
  # classname is a string drawn from a limited set of labels configured for each ImageLabelSet.
  #
  # method target_to_count_hash counts the number of each classname occuring in a particular target string.
  # The returned value is a hash with each key representing a particular classname with at least one occurrence
  # in the target string. The key's corresponding value is the number of occurrences of that classname in
  # the target string.
  def target_to_count_hash(target)
    targetJSON = JSON.parse(target)
    classes = targetJSON.map{ |t| t["classname"] }
    counts = Hash.new(0)
    classes.each do |v|
      counts[v] += 1
    end
    return counts
  end

  # In order to compare a set of ImageLabels associated with a particular Image,
  # it's necessary to first gather the entire set of object types (classnames)
  # present in competing ImageLabels.
  #
  # The main use-case of this method is to transform individual target-count-hashes
  # to a set of target-count-hashes all containing the same keys. This provides
  # a consistent basis for comparison where non-present object types/classnames
  # are represented with a value of 0 at the corresponding key, instead of the
  # key being missing.
  def classes_present_in_all_image_labels
    counts_hash_list = all_targets_count_hash()
    class_list = []
    keys = counts_hash_list.inject(class_list) {|cl, ch| ((ch.keys.count > 0) ? cl.push(ch.keys) : cl)  }
    return keys.flatten(1).uniq
  end

  #This method combines classes_present_in_all_image_labels
  # with all_targets_count_hash in order to provide a
  # set of target-count-hashes where classnames/object types
  # present in some images but not others are represented
  # with a value of 0 at the corresponding key location.
  # Thus the resulting target-count-hashes are comparable
  # on a consistent basis.
  def all_targets_count_hash_padded
    counts_hash_list = all_targets_count_hash
    classes_list = classes_present_in_all_image_labels
    counts_hash_list.each do  |counts_hash|
      classes_list.each do  |this_class|
        if(not counts_hash.key? this_class)
          counts_hash[this_class] = 0
        end
      end
    end
    return counts_hash_list
  end

  # Add the values for each key in two hashes.
  # Result undefined if hashes contain different keys.
  def add_count_hashes(hash1, hash2)
    result = hash1.merge(hash2) {|key,val1,val2| val1+val2}
  end

  # Calculate the absolute difference in value for a given key in two hashes.
  # Result undefined if hashes contain different keys.
  def absolute_difference_count_hashes(hash1, hash2)
    result = hash1.merge(hash2) {|key,val1,val2| (val1-val2).abs }
  end

  # Takes a list of hashes mapping strings to numbers.
  # Each hash is assumed to contain the same set of keys.
  # The returned hash contains the average value of the corresponding key for each hash in the input list.
  def average_counts_hash
    counts_padded = all_targets_count_hash_padded()
    class_list = classes_present_in_all_image_labels()
    class_totals_hash = Hash[class_list.map {|c| [c,0] }]
    class_totals_hash = counts_padded.inject(class_totals_hash) { |totals, counts_hash| add_count_hashes(totals, counts_hash) }
    class_averages = Hash.new
    class_totals_hash.each do |key,value|
      class_averages[key] = (value.to_f/counts_padded.count.to_f).round(1)
    end
    return class_averages
  end

  before_destroy {|image|
    image.image_labels.destroy_all
  }

end
