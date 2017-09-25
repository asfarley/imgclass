class CreateJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :jobs do |t|
      t.references :user, foreign_key: true
      t.references :image_label_set, foreign_key: true

      t.timestamps
    end
  end
end
