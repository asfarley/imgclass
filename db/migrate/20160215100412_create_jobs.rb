class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.references :image_label_set, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
