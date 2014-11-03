class CircleCiProjectDecorator < ProjectDecorator

  def current_build_url
    "https://circleci.com/api/v1/project/#{object.circleci_username}/#{object.ci_build_name}?circle-token=#{object.circleci_auth_token}"
  end

end
