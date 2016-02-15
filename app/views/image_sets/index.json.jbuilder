json.array!(@image_sets) do |image_set|
  json.extract! image_set, :id
  json.url image_set_url(image_set, format: :json)
end
