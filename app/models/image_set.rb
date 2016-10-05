class ImageSet < ActiveRecord::Base
  require 'fileutils'
  include ImageFileUtils

  has_many :images
  has_one :image_label_set

  # path to local dir with images
  def local_dir
    dir_for_set(id)
  end
end
