class CreateImageLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :image_labels do |t|
      t.references :label, foreign_key: true
      t.references :image, foreign_key: true
      t.references :user, foreign_key: true
      t.references :job, foreign_key: true
      t.string :target

      t.timestamps
    end
  end
end
