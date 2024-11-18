require 'net/http'
require 'json'
require 'uri'
require 'open-uri'

class RendersController < ApplicationController
  def index
    @renders = Render.all
    @models = Model.pluck(:id, :name).to_h
    @sort = [:model_id, :steps, :prompt]
    @filters = [:render_type, :steps, :loras, :model_id]
    @filter_options = {}
    @filter_options = get_filter_options(@filters, @filter_options, Render.all)
    # Take filter symbols
    @renders = sorted_records(Render.all, params[:sort_by], @sort)
    @renders = apply_filter_conditions(@filters, params, @renders)
    
    @pagy, @renders = pagy(@renders)
  end

  def new
    @render = Render.new 
    @models = Model.all
    @loras = Lora.all
  end

  def show
    @render = Render.find(params[:id])
  end

  def create
    @render = Render.new(filtered_params.except(:lora_scales))

    @models = Model.all
    lora_ids = params[:render][:lora_ids] || []
    loras = Lora.where(id: lora_ids)
    @num_outputs = params[:num_outputs]

    # Lora Triggers
    @render.prompt = process_lora_triggers(@render.prompt, loras) if loras.present?

    # Tokenize
    if loras.present?
      loras.each do |lora| 
        lora.url_src = tokenize_lora(lora)
      end
    end

    if @render.save
      # Iterate through LoRAs to add LoRA Scale to RenderLora Join Table
      process_lora_scales(@render, params[:render][:lora_scales])

      # Generate image url from Replicate -> Inputting render object and array of url_src from Lora(s)
      image_urls = generate_image_via_api(@render, loras)
      render_save_images(image_urls, @render) if image_urls

      redirect_to renders_path, notice: 'Render was successfully created.'
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
    params.require(:render).permit(
      :render_type,
      :prompt,
      :model_id,
      :guidance_scale,
      :guidance_scale_min,
      :guidance_scale_max,
      :guidance_scale_step,
      :steps,
      :num_outputs,
      :lora_scale_range_min,
      :lora_scale_range_max,
      :lora_scale_range_step,
    )
  end

  def filtered_params
    render_params.tap do |params|
      case params[:render_type]
      when "Image"
        params.except(:guidance_scale_min, :guidance_scale_max, :guidance_scale_step, :lora_scale_range_min, :lora_scale_range_max, :lora_scale_range_step)
      when "Lora Test"
        params.except(:guidance_scale)
      end

      params.delete_if { |_, value| value.blank? }
    end
  end

  def process_lora_scales(render, lora_scales)
    lora_scales.each do |lora_id, lora_scale|
      render.render_loras.create(lora_id: lora_id, scale: lora_scale)
    end
  end

  def process_lora_triggers(prompt, loras)
    loras.each_with_index do |lora, index|
      placeholder = "{lora_#{index + 1}}"
      prompt = prompt.gsub(placeholder, lora.trigger)
    end
    prompt
  end

  def render_save_images(image_urls, render)
    image_urls.each do |image_url|
      image = render.images.create(filename: File.basename(image_url))
      image.image.attach(io: URI.open(image_url), filename: File.basename(image_url))
    end
  end

  def generate_image_via_api(render, loras)
    case render.model.platform
    when "Replicate"
      return replicate_image(render, loras)
    end
  end

  def replicate_image(render, loras)
    uri = URI('http://localhost:5000/replicate/generate_image')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })

    data = {
      prompt: render.prompt,
      base_model: render.model.url_src,
      g_scale: render.guidance_scale,
      steps: render.steps,
      lora_1: loras[0]&.url_src,
      lora_2: loras[1]&.url_src,
      l1: render.render_loras.where(lora_id: loras[0]&.id).pluck(:scale).first,
      l2: render.render_loras.where(lora_id: loras[1]&.id).pluck(:scale).first,
      num_outputs: render.num_outputs
    }

    Rails.logger.info("Sending request to Flask app: #{data.to_json}")

    request.body = data.to_json

    begin
      # Sending request to Flask
      response = http.request(request)
      if response.code == '200'
        json_response = JSON.parse(response.body)
        return json_response['images']
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
