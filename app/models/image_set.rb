class ImageSet < ActiveRecord::Base
  require 'image_file_utils'
  include ImageFileUtils

  has_many :images
  has_one :image_label_set

  # path to local dir with images
  def local_dir
    dir_for_set(id)
  end

  def vdir
    vdir_for_set(id)
  end

end
