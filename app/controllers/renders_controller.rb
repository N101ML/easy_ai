require 'net/http'
require 'json'
require 'uri'
require 'open-uri'

class RendersController < ApplicationController
  def index
    @renders = Render.includes(images: { image_attachment: :blob})
    @models = Model.pluck(:id, :name).to_h
    @sort_options = %w[model_id steps prompt]
    @filters = %w[render_type steps loras model_id]

    # Prepare filters
    @filter_options = {}
    @filters.each do |filter|
      case filter
      when 'loras'
        @filter_options[filter] = Lora.pluck(:name).uniq
      when 'model_id'
        @filter_options[filter] = Model.pluck(:id)
      else
        @filter_options[filter] = Render.pluck(filter).uniq.compact
      end
    end

    # Filtering
    if params[:filters].present?
      params[:filters].each do |filter|
        key, value = filter.split(':')
        if @filters.include?(key)
          case key
          when 'loras'
            @renders = @renders.joins(:loras).where(loras: { name: value}).distinct
          else
            @renders = @renders.where(key => value)
          end
        end
      end
    end

    # Sorting
    if params[:sort_by].present? && @sort_options.include?(params[:sort_by])
      @renders = @renders.order(params[:sort_by])
    end

    @pagy, @renders = pagy(@renders)
  end


  def new
    @render = Render.new 
    @models = Model.all
    @loras = Lora.all
    @fine_tunes = FineTune.all
  end

  def show 
    @render = Render.find(params[:id])
  end

  def create
    # Lora Scales are not part of Render model - but needed for RenderLora Join Table
    @render = Render.new(filtered_params.except(:lora_scales, :lora_ids))
    @models = Model.all
    loras = Lora.where(id: params[:render][:lora_ids]) if params[:render][:lora_ids]

    # params[:lora_scales] format: "lora_scales": { "lora_id": "lora_scale" } or nil if no lora's present
    case @render.render_type
    when 'Image'
      render_image(params[:prompt], params[:model_id], params[:guidance_scale], params[:steps], params[:num_outputs], loras, params[:render][:lora_scales])
    when 'Sample'
      render_sample()
    when 'Lora Test'
      render_lora_test()
    end


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
      # process_lora_scales(@render, params[:render][:lora_scales])
      process_lora_scales(@render, loras)

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

  def render_lora_test(lora_scale_range_step, lora_scale_range_min, lora_scale_range_max, guidance_scale_step, guidance_scale_min, guidance_scale_max, step_step, step_min, step_max)
    initialize_lora_test_params(lora_scale_range_step, lora_scale_range_min, lora_scale_range_max, guidance_scale_step, guidance_scale_min, guidance_scale_max, step_step, step_min, step_max)
    @loras_range.each do |lora_scale|
      @guidance_range.each do |g_scale|
        @step_range.each do |step|
          if @render.save
            :num_outputs
          end
        end
      end
    end
  end

  def initialize_lora_test_params(lora_scale_range_step, lora_scale_range_min, lora_scale_range_max, guidance_scale_step, guidance_scale_min, guidance_scale_max, step_step, step_min, step_max)
    @loras_range = render_ranges(lora_scale_range_min, lora_scale_range_max, lora_scale_range_step).uniq
    @guidance_range = render_ranges(guidance_scale_min, guidance_scale_max, guidance_scale_step).uniq
    @step_range = render_ranges(step_min, step_max, step_step)
  end

  private

  def render_image(prompt, model, guidance_scale, steps, outputs, loras, lora_scales)
    puts "from the render_image!"
    loras = process_loras(loras) if loras
    puts "from the render_image after loras"
    if @render.save
      # Add to RenderJoin
      puts "inside render save"
      process_lora_scales(@render, lora_scales) if loras
      puts "after process lora scales"
      image_urls = generate_image_via_api(@render, loras)
      puts "after image_urls"
      render_save_images(image_urls, @render) if image_urls
      puts "after render_save_images"
      redirect_to renders_path, notice: 'Render was successfully created.'
    else
      puts "no render save"
      Rails.logger.info(@render.errors.full_messages)
      @models = Model.all 
      render :new
    end
    # check for outputs
    # render save
      # process LoraRender Join Table
      # Generate Image via API
      # Create and save Image
  end

  # Takes an array of loras or empty array - returns an array of loras (or an empty array)
  def process_loras(loras)
    # Tokenize and process prompt for each lora - Returns an array
    loras.each do |lora|
      lora.url_src = tokenize_lora(lora)
    end
    @render.prompt = process_lora_triggers(@render.prompt, loras)
    loras
  end

  def render_ranges(min, max, step)
    (min..max).step(step).map { |el| el }
  end

  def render_params
    params.require(:render).permit(
      :render_type,
      :prompt,
      :model_id,
      :fine_tune_id,
      :guidance_scale,
      :guidance_scale_min,
      :guidance_scale_max,
      :guidance_scale_step,
      :steps,
      :num_outputs,
      :lora_scale_range_min,
      :lora_scale_range_max,
      :lora_scale_range_step,
      lora_ids: [],
      lora_scales: {}
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

      # Ensure lora_scales and lora_ids are retained
      params[:lora_scales] ||= {}
      params[:lora_ids] ||= []
    end
  end

  def render_lora_test()

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
    puts "inside replicate image"
    uri = URI('http://localhost:5000/replicate/generate_image')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    # Check for fine-tune
    model = render.fine_tune_id ? FineTune.find(render.fine_tune_id).platform_source : render.model.platform_source

    data = {
      prompt: render.prompt,
      base_model: model,
      g_scale: render.guidance_scale,
      steps: render.steps,
      lora_1: loras[0]&.url_src,
      lora_2: loras[1]&.url_src,
      l1: render.render_loras.where(lora_id: loras[0]&.id).pluck(:scale).first,
      l2: render.render_loras.where(lora_id: loras[1]&.id).pluck(:scale).first,
      num_outputs: render.num_outputs
    }
    puts "data: #{data}"
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
