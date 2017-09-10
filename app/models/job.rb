## The Job class represents a (potentially redundant) subset of images in a particular
# ImageLabelSet. The purpose of Job objects is to:
# 1) Break ImageLabelSets into a manageable size for a single worker
# 2) Provide a mechanism for redundantly classifying images in a particular ImageLabelSet in order to guage agreement
#    between users' label responses.

class Job < ActiveRecord::Base
  belongs_to :image_label_set
  belongs_to :user
  has_many :image_labels

  before_destroy :reset_imagelabels

  # Determine whether this job has remaining images to classify.
  def isOpen
    percent_remaining > 0
  end

  # Determine whether this job is complete.
  def isComplete
    ! isOpen
  end

  # Determine the percentage of remaining images to be classified by users.
  def percent_remaining
    totalImages = image_labels.count
    remainingImages = image_labels.count - labelledImagesCount()
    pct = (remainingImages.count.to_f/totalImages)*100.0
    pct.round(1)
  end

  # Determine the percentage of images already classified by users.
  def percent_complete
    totalImages = image_label_set.image_labels.count
    if totalImages == 0
      totalImages = 1;
    end
    completeImages = image_label_set.labelledImagesCount()
    pct = (completeImages.to_f/totalImages)*100.0
    pct.round(1)
  end

  # Determine the percentage agreement between this job and other jobs containing
  # the same images.
  def percent_agreement
    100.0
  end

  # Clear all image labels in this job.
  def reset_imagelabels
    image_labels.each do |il|
      il.job_id = nil
      il.save
    end
  end


end
