class Render < ApplicationRecord
  belongs_to :model
  validates :guidance_scale, presence: true, numericality: { greater_than: 0 }
end
