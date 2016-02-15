json.array!(@labels) do |label|
  json.extract! label, :id, :text, :label_set_id
  json.url label_url(label, format: :json)
end
