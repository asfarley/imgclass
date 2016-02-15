json.array!(@image_labels) do |image_label|
  json.extract! image_label, :id, :image_id, :label_id, :user_id
  json.url image_label_url(image_label, format: :json)
end
