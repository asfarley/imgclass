class AddBoundingBoxModeBooleanToImageLabelSets < ActiveRecord::Migration[5.0]
  def change
    add_column :image_label_sets, :bounding_box_mode, :boolean
  end
end
