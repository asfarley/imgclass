class AddJobToImageLabel < ActiveRecord::Migration
  def change
    add_column :image_labels, :job_id, :integer
  end
end
