class Model < ApplicationRecord
  has_many :renders, dependent: :nullify
  has_many :render_loras, through: :renders
  has_many :loras
  has_many :fine_tunes

  validates :name, :company, :platform, :platform_source, presence: true

  scope :replicate, -> { where(platform: "Replicate") }
  scope :civitai, -> { where(platform: "Civitai") }
  scope :hugging_face, -> { where(platform: "Hugging Face")}
end
