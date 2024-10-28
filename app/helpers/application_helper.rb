module ApplicationHelper
  def convert_platform_url(platform, url)
    case platform
    when 'Hugging Face'
      link_to 'Hugging Face', "https://huggingface.co/#{url}", target: "_blank", rel: "noopener"
    else
      link_to platform, url, target: "_blank", rel: "noopener"
    end
  end
end