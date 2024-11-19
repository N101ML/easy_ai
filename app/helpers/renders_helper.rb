module RendersHelper
  def render_model_prompt_content(render)
    if render.model.nil?
      content_tag(:div, class: "text-center rounded-md") do
         concat content_tag(:div, render.prompt)
      end
    else
      content_tag(:div, class: "text-center rounded-md") do
        concat content_tag(:div, render.model.name, class: "border rounded-md")
        concat content_tag(:div, render.prompt)
      end
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
