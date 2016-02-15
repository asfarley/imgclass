json.array!(@image_label_sets) do |image_label_set|
  json.extract! image_label_set, :id, :image_set_id, :label_set_id, :user_id
  json.url image_label_set_url(image_label_set, format: :json)
end
