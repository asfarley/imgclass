class DropImageSetsTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :image_sets
  end
end
