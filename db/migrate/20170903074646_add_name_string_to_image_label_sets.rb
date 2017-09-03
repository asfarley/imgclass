class AddNameStringToImageLabelSets < ActiveRecord::Migration[5.0]
  def change
    add_column :image_label_sets, :name, :string
  end
end
