module LorasHelper
  def lora_url_platform(lora)
    content_tag(:div, class: "text-center rounded-md") do
      concat content_tag(:div, convert_platform_url(lora.platform, lora.url_src), class: "border rounded-md")
    end
  end
end
