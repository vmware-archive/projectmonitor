class SemaphoreProjectDecorator < Draper::Decorator
  def current_build_url
    object.parsed_url
  end
end
