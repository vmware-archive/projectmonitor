require "action_mailer"

class ActionMailer::Base
  def multipart(template_name, assigns)
    content_type 'multipart/alternative'

    part :content_type => "text/plain",
         :body => render("#{template_name}.plain.erb", assigns)

    part :content_type => "text/html",
         :body => render("#{template_name}.html.erb", assigns)
  end
end
