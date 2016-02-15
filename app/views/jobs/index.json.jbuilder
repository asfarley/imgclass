json.array!(@jobs) do |job|
  json.extract! job, :id, :image_label_set_id, :user_id
  json.url job_url(job, format: :json)
end
