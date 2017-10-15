class AddTargetStringToImageLabels < ActiveRecord::Migration[5.0]
  def change
    add_column :image_labels, :target, :string
  end
end
