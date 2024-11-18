class Model < ApplicationRecord
  has_many :renders, dependent: :destroy
  has_many :render_loras, through: :renders
  has_many :loras

  validates :name, :company, :platform, :platform_source, presence: true

  scope :replicate, -> { where(platform: "Replicate") }
  scope :civitai, -> { where(platform: "Civitai") }
  scope :hugging_face, -> { where(platform: "Hugging Face")}
end
