class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  before_filter :adjust_format_for_iphone

  filter_parameter_logging :password

  protected

  def adjust_format_for_iphone
    request.format = :iphone if iphone_user_agent?
  end

  def iphone_request?
    return (request.subdomains.first == "iphone" || params[:format] == "iphone")
  end

  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end
end
