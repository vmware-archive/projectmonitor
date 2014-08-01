class TddiumProjectDecorator < ProjectDecorator

  def current_build_url
    "#{object.tddium_base_url}/dashboard?auth_token=#{object.tddium_auth_token}"
  end

end
