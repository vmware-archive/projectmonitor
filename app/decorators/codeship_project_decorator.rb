class CodeshipProjectDecorator < ProjectDecorator

  def current_build_url
    "https://www.codeship.io/projects/#{object.ci_build_identifier}"
  end
end
