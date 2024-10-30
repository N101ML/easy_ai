class Training < ApplicationRecord
  belongs_to :model

  has_one_attached :zip_file
  has_one_attached :model_weights

  validates :steps, :lora_rank, :optimizer, :trigger_word, presence: true
end
