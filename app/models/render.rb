class Render < ApplicationRecord
  belongs_to :model
  has_many :render_loras, dependent: :destroy
  has_many :loras, through: :render_loras
  has_many :images, dependent: :destroy

  validates :guidance_scale, presence: true, numericality: { greater_than: 0 }
  validates :prompt, presence: true

  has_one_attached :file

  accepts_nested_attributes_for :render_loras, allow_destroy: true
end
