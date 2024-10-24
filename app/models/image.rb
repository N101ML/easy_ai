class Image < ApplicationRecord
  belongs_to :image_render, class_name: "ImageRender"
  has_one_attached :file
end
