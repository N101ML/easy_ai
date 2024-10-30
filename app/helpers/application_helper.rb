module ApplicationHelper
  def html_url_platform(object)
    content_tag(:div, class: "rounded-md border rounded-md text-center p-2") do
    concat link_to object.platform, object.platform_url, target: "_blank", rel: "noopener"
    end
  end
end