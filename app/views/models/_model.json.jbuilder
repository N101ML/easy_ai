json.extract! model, :id, :name, :url_src, :created_at, :updated_at
json.url model_url(model, format: :json)
