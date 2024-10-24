class Render < ApplicationRecord
  belongs_to :model
  has_many :renders_loras
  has_many :loras, through: :renders_loras

  validates :guidance_scale, presence: true, numericality: { greater_than: 0 }
  validates :prompt, presence: true
end
