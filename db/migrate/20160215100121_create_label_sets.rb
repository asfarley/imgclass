class CreateLabelSets < ActiveRecord::Migration
  def change
    create_table :label_sets do |t|

      t.timestamps null: false
    end
  end
end
