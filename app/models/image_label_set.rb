class ImageLabelSet < ActiveRecord::Base
  require 'fileutils'
  belongs_to :image_set
  belongs_to :label_set
  belongs_to :user
  has_many :jobs

  before_destroy {|ils|
    FileUtils.rm_rf("/srv/imgclass/public/images/#{ils.image_set_id}")
    ImageSet.find(ils.image_set_id).images.destroy_all
    ImageSet.find(ils.image_set_id).destroy
    LabelSet.find(ils.label_set_id).labels.destroy_all
    LabelSet.find(ils.label_set_id).destroy
  }
end
