def ImageRendersController < ApplicationController
  def new
    @image_render = ImageRender.new
  end

  def create
    @image_render = ImageRender.new(image_render_params)

    if @image_render.save
      @image_render.create_image(file: params[:image_render][:file])
      redirect_to @image_render, notice: "Image rendered successfully"
    else
      render :new
    end
  end

  private

  def image_render_params
    params.require(:image_render).permit(:guidance_scale, :model_id)
  end
end