## The User class represents workers who will perform image classification and labelling.
# Users may classify images; they cannot create new image sets or assign jobs to other users.

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :image_label_sets
  has_many :jobs
  has_many :image_labels, through: :jobs

  def remaining_work_items
    il_total = 0
    jobs.each do |job|
      il_total += (job.image_labels.select{ |il| il.target.nil? }).count
    end
    return il_total
  end

  def get_next_work_item
    image_labels.select{ |il| il.target.nil? }.first
  end

  def total_work_items
    il_total = 0
    jobs.each do |job|
      il_total += job.image_labels.count
    end
    return il_total
  end

  def progress_percentage
    total = total_work_items()
    if (total == 0)
      total = 1 #Prevent division by zero
    end
    remaining = remaining_work_items()
    percent_remaining = 100.0*(remaining.to_f/total.to_f)
    percent_progress = 100.0 - percent_remaining
  end

  def is_worker
    if (roles.nil?)
      return true
    end
    return (not roles.include? "admin")
  end

  def is_active_worker
    if(roles.nil?)
      return false
    end
    return (roles.include? "worker" and not roles.include? "inactive" and not roles.include? "disabled")
  end

end
