class DeleteBbModeFromImageLabelSets < ActiveRecord::Migration[5.0]
  def change
    remove_column :image_label_sets, :bounding_box_mode
  end
end
