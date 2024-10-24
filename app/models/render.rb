class Render < ApplicationRecord
  belongs_to :model
  has_many :renders_loras
  has_many :loras, through: :renders_loras

  validates :guidance_scale, presence: true, numericality: { greater_than: 0 }
  validates :prompt, presence: true

  validate :validate_lora_scales

  private

  def validate_lora_scales
    if loras.any?
      renders_loras.each do |renders_lora|
        if renders_lora.scale.blank?
          errors.add(:base, "Scale must be present for each associated LoRA")
        elsif !renders_lora.scale.is_a?(Numeric)
          errors.add(:base, "Scale must be a numeric value for each associated LoRA")
        end
      end
    end
  end
end
