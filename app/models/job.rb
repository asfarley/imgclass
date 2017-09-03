class Job < ActiveRecord::Base
  belongs_to :image_label_set
  belongs_to :user
  has_many :image_labels

  before_destroy :reset_imagelabels


  def isOpen
    percent_remaining > 0
  end

  def isComplete
    ! isOpen
  end

  def percent_remaining
    totalImages = image_labels.count
    remainingImages = image_labels.select{ |il| il.label.nil? }
    pct = (remainingImages.count.to_f/totalImages)*100.0
    pct.round(1)
  end

  def percent_complete
    totalImages = image_label_set.image_labels.count
    if totalImages == 0
      totalImages = 1;
    end
    completeImages = image_label_set.image_labels.select{ |il| (il.label.nil? == false) }
    pct = (completeImages.count.to_f/totalImages)*100.0
    pct.round(1)
  end

  def percent_agreement
    100.0
  end

  def reset_imagelabels
    image_labels.each do |il|
      il.job_id = nil
      il.save
    end
  end


end
