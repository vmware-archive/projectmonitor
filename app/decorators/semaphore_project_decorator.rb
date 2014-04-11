class SemaphoreProjectDecorator < ProjectDecorator
  def current_build_url
    object.parsed_url
  end
end
