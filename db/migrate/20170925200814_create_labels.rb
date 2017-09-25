class CreateLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :labels do |t|
      t.references :image_label_set, foreign_key: true
      t.string :text
      t.timestamps
    end
  end
end
