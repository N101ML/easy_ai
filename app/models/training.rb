class Training < ApplicationRecord
  belongs_to :model

  has_one_attached :zip_file
  has_one_attached :model_weights
end
