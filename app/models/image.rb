class Image < ApplicationRecord
  belongs_to :render
  has_one_attached :file
end
