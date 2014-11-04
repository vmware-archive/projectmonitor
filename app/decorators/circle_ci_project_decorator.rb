class CircleCiProjectDecorator < ProjectDecorator

  def current_build_url
    "https://circleci.com/api/v1/project/#{object.circleci_username}/#{object.ci_build_identifier}?circle-token=#{object.ci_auth_token}"
  end

end
