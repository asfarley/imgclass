class CreateImageSets < ActiveRecord::Migration
  def change
    create_table :image_sets do |t|

      t.timestamps null: false
    end
  end
end
