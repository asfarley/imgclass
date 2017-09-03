class RemoveOutdatedSetIndexesImageLabelSet < ActiveRecord::Migration[5.0]
  def change
    remove_column :image_label_sets, :index_image_label_sets_on_image_set_id
    remove_column :image_label_sets, :index_image_label_sets_on_label_set_id
  end
end
