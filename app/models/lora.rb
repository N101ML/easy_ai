class Lora < ApplicationRecord
  belongs_to :model
  has_many :render_loras, class_name: "RenderLora", dependent: :destroy
  has_many :renders, through: :render_loras

  scope :replicate, -> { where(platform: "Replicate") }
  scope :civitai, -> { where(platform: "Civitai") }
  scope :hugging_face, -> { where(platform: "Hugging Face")}
end
