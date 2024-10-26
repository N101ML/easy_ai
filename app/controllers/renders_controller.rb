require 'net/http'
require 'json'
require 'uri'
require 'open-uri'

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
    lora_ids = (params[:render][:lora_ids] || []).reject(&:blank?).map { |id| id.to_f }
    loras = Lora.where(id: lora_ids)
    lora_scales = params[:lora_scales] || []
    puts "lora scales: #{lora_scales}"
    # Lora Triggers
    @render.prompt = process_lora_triggers(@render.prompt, loras) if loras.present?

    # Tokenize
    if loras.present?
      loras.each do |lora|
        lora.url_src = tokenize_lora(lora)
        puts "lora tokenized: #{lora.url_src}"
      end
    end

    if @render.save
      lora_ids = params[:render][:lora_ids] || []
      lora_ids.each_with_index do |lora_id, index|
        scale = params["lora_scale_#{index + 1}"].to_f
        @render.render_loras.create(lora_id: lora_id, scale: scale)
      end

      # Generate image url from Replicate -> Inputting render object and array of url_src from Lora(s)
      image_url = generate_image_via_api(@render, loras)

      if image_url
        image = @render.images.create(filename: File.basename(image_url))
        image.image.attach(io: URI.open(image_url), filename: File.basename(image_url))
      end

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
    params.require(:render).permit(:prompt, :render_type, :guidance_scale, :model_id)
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

    uri = URI('http://localhost:5000/generate_image')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    puts "loras from replicate: #{loras}"
    data = {
      prompt: render.prompt,
      model: render.model.url_src,
      lora_1: loras[0]&.url_src,
      lora_2: loras[1]&.url_src,
      l1_scale: render.render_loras.where(lora_id: loras[0]&.id).pluck(:scale).first,
      l2_scale: render.render_loras.where(lora_id: loras[1]&.id).pluck(:scale).first,
      g_scale: render.guidance_scale
    }

    Rails.logger.info("Sending request to Flask app: #{data.to_json}")
    puts "data_file: #{data}"
    request.body = data.to_json

    begin
      response = http.request(request)
      if response.code == '200'
        json_response = JSON.parse(response.body)
        return json_response['image_url']
      else
        Rails.logger.error("Flask app returned an error: #{response.code} - #{response.body}")
        return nil
      end
    rescue StandardError => e
      Rails.logger.error("Error connecting to Flask app: #{e.message}")
      return nil
    end
  end

  def tokenize_lora(lora)
    puts "url_src: #{lora.url_src}"
    case lora.platform
    when 'Civitai'
      if ENV["CIVITAI_API_TOKEN"].present?
        return lora.url_src + '&token=' + ENV["CIVITAI_API_TOKEN"]
      else
        raise "CIVITAI_API_TOKEN environment variable is not set"
      end
    end
    lora.url_src
  end
end
