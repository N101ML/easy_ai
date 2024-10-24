class Lora < ApplicationRecord
  has_many :renders_loras
  has_many :renders, through: :renders_loras
end
