class CreateImageLabelSets < ActiveRecord::Migration[5.0]
  def change
    create_table :image_label_sets do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.boolean :bounding_box_mode

      t.timestamps
    end
  end
end
