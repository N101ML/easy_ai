class FineTunesController < ApplicationController
  before_action :set_fine_tune, only: %i[ show edit update destroy ]
  before_action :set_models

  # GET /fine_tunes or /fine_tunes.json
  def index
    @model = Model.find(params[:model_id])
    @fine_tunes = @model.fine_tunes
  end

  # GET /fine_tunes/1 or /fine_tunes/1.json
  def show
    @fine_tune = FineTune.find(params[:id])
    @model = @fine_tune.model
  end

  # GET /fine_tunes/new
  def new
    @model = Model.find(params[:model_id])
    @fine_tune = @model.fine_tunes.build
    @platforms = @models.map { |model| model.platform }.uniq
  end

  # GET /fine_tunes/1/edit
  def edit
  end

  # POST /fine_tunes or /fine_tunes.json
  def create
    @fine_tune = FineTune.new(fine_tune_params)

    respond_to do |format|
      if @fine_tune.save
        format.html { redirect_to @fine_tune, notice: "Fine tune was successfully created." }
        format.json { render :show, status: :created, location: @fine_tune }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @fine_tune.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fine_tunes/1 or /fine_tunes/1.json
  def update
    respond_to do |format|
      if @fine_tune.update(fine_tune_params)
        format.html { redirect_to @fine_tune, notice: "Fine tune was successfully updated." }
        format.json { render :show, status: :ok, location: @fine_tune }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @fine_tune.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fine_tunes/1 or /fine_tunes/1.json
  def destroy
    @fine_tune.destroy!

    respond_to do |format|
      format.html { redirect_to fine_tunes_path, status: :see_other, notice: "Fine tune was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fine_tune
      @fine_tune = FineTune.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fine_tune_params
      params.require(:fine_tune).permit(:name, :platform, :platform_source, :platform_link, :model_id)
    end

    def set_models
      @models = Model.all
    end
end
