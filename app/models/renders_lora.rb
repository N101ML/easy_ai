class RendersLora < ApplicationRecord
  belongs_to :render
  belongs_to :lora

  validates :scale, presence: true, numericality: true, if: -> { lora.present? }
end
