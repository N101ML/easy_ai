require 'net/http'
require 'json'

class RendersController < ApplicationController
  def index
    @renders = Render.all
  end

  def new
    @render = Render.new
    @models = Model.all
  end

  def show
    @render = Render.find(params[:id])
  end

  def create
    @render = Render.new(render_params)
    @models = Model.all
    # Initialize lora locals
    lora_ids = (params[:render][:lora_ids] || []).reject(&:blank?)
    loras = Lora.where(id: lora_ids)
    valid_scales = true

    tokenize_loras(loras) if loras.present?

    lora_ids.each_with_index do |lora_id, index|
      scale = params["lora_scale_#{index + 1}"]
      if scale.blank?
        @render.errors.add(:base, "Scale mys be present for LoRA# #{index + 1}")
        valid_scales = false
      elsif !scale.is_a?(Numeric) && !scale.to_s.match(/\A\d+(\.\d+)?\z/)
        @render.errors.add(:base, "Scale must be a numeric value for Lora# #{index + 1}")
      end
    end

    if valid_scales && @render.save
      # The Lora scale is added, after save, to the renders_loras join table
      lora_ids.each_with_index do |lora_id, index|
        puts "lora_id: #{lora_id}"
        puts "params: #{params}"
        scale = params["lora_scale_#{index + 1}"].to_f  # Convert scale to float
        puts "scale: #{scale}"
        @render.render_loras.create(lora_id: lora_id, scale: scale)
      end

      # Generate image url from Replicate -> Inputting render object and array of url_src from Lora(s)
      image_url = generate_image_via_api(@render, loras)

      @render.images.create(filename: File.basename(image_url)) if image_url
      

      redirect_to @render, notice: 'Render was successfully created.'
    else
      Rails.logger.info(@render.errors.full_messages)
      @models = Model.all 
      render :new
    end
  end

  def destroy
    @render = Render.find(params[:id])
    @render.destroy!

    respond_to do |format|
      format.html { redirect_to renders_path, status: :see_other, notice: "Render was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def render_params
    params.require(:render).permit(:prompt, :render_type, :guidance_scale, :model_id, lora_ids: [])
  end

  def process_lora_triggers(prompt, loras)
    loras.each_with_index do |lora, index|
      placeholder = "{lora_#{index + 1}}"
      prompt = prompt.gsub(placeholder, lora.trigger)
    end
    prompt
  end

  def generate_image_via_api(render, loras)
    case render.model.platform
    when "Replicate"
      replicate_image(render, loras)
    end
  end

  def replicate_image(render, loras)
    # Add token to lora source
    loras.each do |lora|
      lora.url_src = lora.url_src + ENV["REPLICATE_API_TOKEN"]
    end

    uri = URI('http://localhost:5000/generate_image')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })

    data = {
      prompt: render.prompt,
      model: render.model,
      lora_1: loras[0]&.url_src,
      lora_2: loras[1]&.url_src,
      l1_scale: render.renders_loras.where(lora_id: loras[0]&.id).pluck(:scale).first,
      l2_scale: render.renders_loras.where(lora_id: loras[1]&.id).pluck(:scale).first,
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

  def tokenize_loras(loras)
    loras.each do |lora|
      case lora.platform
      when 'Civitai'
        lora.url_src = lora.url_src + ENV["CIVITAI_API_TOKEN"]
      end
    end
  end
end
