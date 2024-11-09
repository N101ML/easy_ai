module RendersHelper
  def render_type_content(render)
    if render.images.any?
      num_images = render.images.size > 1 ? "grid grid-cols-2 gap-2" : "object-fit"
      content_tag(:div, class: "#{num_images}") do
        render.images.map do |image|
          if image.image.attached?
            link_to(image_tag(url_for(image.image), alt: "Render Image", class: ""), render_path(render), target: "_top")
          else
            "No Image"
          end
        end.join.html_safe
      end
    else
      "No Image"
    end
  end


  def render_model_prompt_content(render)
    content_tag(:div, class: "text-center rounded-md") do
      concat content_tag(:div, render.model.name, class: "border rounded-md")
      concat content_tag(:div, render.prompt)
    end
  end

  def render_lora_info_content(render)
    content_tag(:div, class: "rounded-md border rounded-md text-center p-2") do
      render.render_loras.each do |render_lora|
        concat content_tag(:div, "<strong>Lora: #{render_lora.lora.name}</strong> - Scale: #{render_lora.scale}".html_safe)
      end
    concat content_tag(:div, "<strong>Inference Steps:</strong> #{render.steps}".html_safe)
    end
  end
end
