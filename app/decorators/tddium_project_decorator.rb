class TddiumProjectDecorator < ProjectDecorator

  def current_build_url
    "https://api.tddium.com/dashboard?auth_token=#{object.tddium_auth_token}"
  end

end
