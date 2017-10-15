class ChangeImageSetIdToImageLabelSetIdImages < ActiveRecord::Migration[5.0]
  def change
    rename_column :images, :image_set_id, :image_label_set_id
  end
end
