class RenderLora < ApplicationRecord
  belongs_to :render
  belongs_to :lora

  # validates :scale, presence: true, if: -> { lora_id.present? }
end
