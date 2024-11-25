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
    return link_to("No Image", url_for(object), target: "_top") unless object.images.any?

    num_images_class = object.images.size > 1 ? "grid grid-cols-2 gap-2" : ""
    
    content_tag(:div, class: num_images_class) do
      object.images.map do |image|
        link_path = thumbnail_link_target(object, image, link_target)
        link_to(image_tag(url_for(image.image), alt: "Image"), link_path, target: "_top")
      end.join.html_safe
    end
  end

  def titleize_filter(option, filter)
    if filter == :model_id
      return @models[option.to_i]
    else
      return option
    end
  end

  def renders_table_headers
    [
      { label: "Type", basis: "1/4", content: ->(render) { format_thumbnail(render) } },
      { label: "Model/Prompt", basis: "1/2", content: ->(render) { render_model_prompt_content(render) } },
      { label: "LoRA Details", basis: "1/4", content: ->(render) { render_lora_info_content(render) }, class: "flex justify-center items-start" }
    ]
  end

  def loras_table_headers
    [
      { label: "Name", basis: "1/4", content: ->(lora) { link_to lora.name, lora_path(lora), target: "_top" }, class: "flex justify-center items-center" },
      { label: "Platform", basis: "1/4", content: ->(lora) { html_url_platform(lora) }, class: "flex justify-center items-center" },
      { label: "Trigger", basis: "1/4", content: ->(lora) { lora.trigger }, class: "flex items-center" },
      { label: "Model", basis: "1/4", content: ->(lora) { html_url_platform(lora) if lora.model }, class: "flex justify-center items-center" }
    ]
  end
end