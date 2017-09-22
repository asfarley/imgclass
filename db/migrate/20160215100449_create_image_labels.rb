class CreateImageLabels < ActiveRecord::Migration
  def change
    create_table :image_labels do |t|
      t.references :image, index: true, foreign_key: true
      t.references :label, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
