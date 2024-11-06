class TrainingsController < ApplicationController
  before_action :set_training, only: %i[ show edit update destroy ]

  # GET /trainings or /trainings.json
  def index
    @trainings = Training.all
  end

  # GET /trainings/1 or /trainings/1.json
  def show
    @training = Training.find(params[:id])
  end

  # GET /trainings/new
  def new
    @training = Training.new
    @models = Model.all
  end

  # GET /trainings/1/edit
  def edit
  end

  # POST /trainings or /trainings.json
  def create
    @training = Training.new(training_params)

    respond_to do |format|
      if @training.save
        format.html { redirect_to @training, notice: "Training was successfully created." }
        format.json { render :show, status: :created, location: @training }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @training.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trainings/1 or /trainings/1.json
  def update
    respond_to do |format|
      if @training.update(training_params)
        format.html { redirect_to @training, notice: "Training was successfully updated." }
        format.json { render :show, status: :ok, location: @training }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @training.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trainings/1 or /trainings/1.json
  def destroy
    @training.destroy!

    respond_to do |format|
      format.html { redirect_to trainings_path, status: :see_other, notice: "Training was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_training
      @training = Training.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def training_params
      params.require(:training).permit(:name, :model_id, :steps, :optimizer, :destination, :trigger_word, :resolution, :zip_file)
    end

    def training(training)
      case training.model.platform
      when "Replicate"
        training_replicate(training)
      end
    end

    def training_replicate(training, zip_file)
      training.destination = create_destination_model_replicate(training)

      uri = URI('http://localhost:5000/training/replicate')
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })

      data = {
        destination: training.destination,
        version: training.model.url_src,
        steps: training.steps,
        optimizer: training.optimizer,
        trigger_word: training.trigger_word,
        resolution: training.resolution,
        image_zip: zip_file,
      }

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

  #   output = replicate.trainings.create(
  #   destinaion="", # This is the replicate model we are going to save to
  #   version=model,
  #   input={
  #     "steps": 1500,
  #     "lora_rank": 64,
  #     "optimizer": "adamw8bit",
  #     "batch_size": 1,
  #     "resolution": 1024,
  #     "autocaption": True,
  #     "input_images": "", # This should be a zip file that includes captions with separate .txt files for each image
  #     "trigger_word": "",
  #     "learning_rate": 0.0005,
  #     "caption_dropout_rate": 0.05,
  #     "cache_latents_to_disk": False,
  #   },
  # )
end
