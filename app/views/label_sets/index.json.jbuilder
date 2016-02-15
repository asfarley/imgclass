json.array!(@label_sets) do |label_set|
  json.extract! label_set, :id
  json.url label_set_url(label_set, format: :json)
end
