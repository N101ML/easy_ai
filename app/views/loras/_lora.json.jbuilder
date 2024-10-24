json.extract! lora, :id, :name, :url_src, :scale, :trigger, :model_id, :created_at, :updated_at
json.url lora_url(lora, format: :json)
