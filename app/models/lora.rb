class Lora < ApplicationRecord
  belongs_to :model
  has_many :renders_loras
  has_many :renders, through: :renders_loras
end
