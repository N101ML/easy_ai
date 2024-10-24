class RendersLora < ApplicationRecord
  belongs_to :render
  belongs_to :lora

  validates :scale, numericality: true, allow_nil: true
end
