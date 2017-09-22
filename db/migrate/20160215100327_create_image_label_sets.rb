class CreateImageLabelSets < ActiveRecord::Migration
  def change
    create_table :image_label_sets do |t|
      t.references :image_set, index: true, foreign_key: true
      t.references :label_set, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
