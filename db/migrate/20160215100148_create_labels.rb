class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.string :text
      t.references :label_set, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
