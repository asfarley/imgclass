class ChangeLabelSetIdToImageLabelSetIdLabels < ActiveRecord::Migration[5.0]
  def change
    rename_column :labels, :label_set_id, :image_label_set_id
  end
end
