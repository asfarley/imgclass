class RemoveImageSetLabelSetFromImageLabelSet < ActiveRecord::Migration[5.0]
  def change
    remove_column :image_label_sets, :image_set_id
    remove_column :image_label_sets, :label_set_id
  end
end
