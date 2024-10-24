class RendersController < ApplicationController
  def index
    @renders = Render.all
  end

  def new
    @render = Render.new
  end

  def create
    @render = Render.new(render_params)

    lora_ids = params[:render][:lora_ids] || []
    loras = Lora.where(id: lora_ids)

    @render.prompt = process_lora_triggers(@render.prompt, loras)

    if @render.save

      lora_ids.each do |lora_id|
        unless lora_id.blank?
          scale = params["scale_#{lora_id}"] || nil
          @render.renders_loras.create(lora_id: lora_id, scale: scale)
        end
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
end
