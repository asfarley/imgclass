class DropLabelSetsTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :label_sets
  end
end
