module ApplicationHelper
  include Pagy::Frontend
  def html_url_platform(object)
    content_tag(:div, class: "rounded-md border rounded-md text-center p-2") do
    concat link_to object.platform, object.platform_url, target: "_blank", rel: "noopener"
    end
  end

  def thumbnail_link_target(object, image, target_type)
    case target_type
    when :object
      url_for(object)
    when :image
      url_for(image)
    end
  end

  def format_thumbnail(object, link_target: :object)
    return link_to("No Image", url_for(object), target: "_top") unless object.respond_to?(:images) && object.images.any?

    num_images_class = object.images.size > 1 ? "grid grid-cols-2 gap-2" : "object-fit"
    content_tag(:div, class: num_images_class) do
      object.images.map do |image|
        link_path = thumbnail_link_target(object, image, link_target)
        link_to(image_tag(url_for(image.image), alt: "Image"), link_path, target: "_top")
      end.join.html_safe
    end
  end
end