class TravisProjectDecorator < ProjectDecorator
  BASE_WEB_URL = "https://travis-ci.org"

  def current_build_url
    "#{BASE_WEB_URL}/#{object.slug}"
  end

end
