class TddiumProjectDecorator < ProjectDecorator

  def current_build_url
    "#{object.ci_base_url}/dashboard?auth_token=#{object.ci_auth_token}"
  end

end
