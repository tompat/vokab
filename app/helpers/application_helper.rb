module ApplicationHelper

  def model_errors_as_html(resource)
    content_tag(:ul) do
      resource.errors.full_messages.collect do |error_message|
        concat(content_tag(:li, error_message))
      end
    end
  end

end
