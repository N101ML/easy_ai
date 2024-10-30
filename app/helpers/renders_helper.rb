module RendersHelper
  def render_type_content(render)
    if render.images.first&.image&.attached?
      link_to(image_tag(url_for(render.images.first.image), alt: "Render Image", class: "object-cover"), image_path(render.images.first))
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


  # def render_loras_content(render)
  #   content_tag(:div) do
  #     concat content_tag(:div, "<strong>Guidance Scale:</strong> #{render.guidance_scale}".html_safe)
  #     render.render_loras.each do |render_lora|
  #       concat content_tag(:div, "<strong>Lora: #{render_lora.lora.name}</strong> - Scale: #{render_lora.scale}".html_safe)
  #     end
  #     concat content_tag(:div, "<strong>Inference Steps:</strong> #{render.steps}".html_safe)
  #   end
  # end

  def render_lora_info_content(render)
    content_tag(:div, class: "rounded-md border rounded-md text-center p-2") do
      render.render_loras.each do |render_lora|
        concat content_tag(:div, "<strong>Lora: #{render_lora.lora.name}</strong> - Scale: #{render_lora.scale}".html_safe)
      end
    concat content_tag(:div, "<strong>Inference Steps:</strong> #{render.steps}".html_safe)
    end
  end
end
