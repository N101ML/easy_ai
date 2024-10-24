require 'net/http'
require 'json'

class RendersController < ApplicationController
  def index
    @renders = Render.all
  end

  def new
    @render = Render.new
  end

  def create
    @render = Render.new(render_params)

    # Initialize lora locals
    lora_ids = params[:render][:lora_ids] || []
    loras = Lora.where(id: lora_ids)

    # Triggers are processed in prompt
    @render.prompt = process_lora_triggers(@render.prompt, loras)

    if @render.save
      # The Lora scale is added, after save, to the renders_loras join table
      lora_ids.each do |lora_id|
        scale = params["scale_#{lora_id}"] || nil
        @render.renders_loras.create(lora_id: lora_id, scale: scale)
      end

      # Generate image url from Replicate -> Inputting render object and array of url_src from Lora(s)
      image_url = generate_image_via_api(@render, loras)

      if image_url
        @render.create_image(filename: File.basename(image_url))
      end

      redirect_to @render, notice: 'Render was successfully created.'
    else
      render :new
    end
  end

  private

  def render_params
    params.require(:render).permit(:prompt, :guidance_scale, :model_id)
  end

  def process_lora_triggers(prompt, loras)
    loras.each_with_index do |lora, index|
      placeholder = "{lora_#{index + 1}}"
      prompt = prompt.gsub(placeholder, lora.trigger)
    end
    prompt
  end

  def generate_image_via_api(render, loras)
    uri = URI('http://localhost:5000/generate_image')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP.new(uri.path, { 'Content-Type' => 'application/json' })

    data = {
      prompt: render.prompt,
      model: render.model,
      lora_1: lora[0].url_src,
      lora_2: lora[1].url_src,
      l1_scale: render.renders_loras.includes(:loras[0]).scale,
      l2_scale: render.renders_loras.includes(:loras[1]).scale, 
      g_scale: render.guidance_scale
    }
    request.body = data.to_json

    response = http.request(request)

    if response.code == '200'
      json_response = JSON.parse(response.body)
      json_response['image_url']
    else
      nil
    end
  end
end
