class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  before_filter :adjust_format_for_iphone
  before_filter :auth_required?

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

  def auth_required?
    unless logged_in?
      redirect_to login_path if AuthConfig.auth_required
    end
  end
end
