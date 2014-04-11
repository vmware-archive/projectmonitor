class ProjectDecorator < Draper::Decorator
  delegate_all

  def css_id
    "#{object.class.base_class.name.underscore}_#{object.id}"
  end

  def status_in_words
    object.state.to_s
  end

  def css_class
    "project #{status_in_words}"
  end

  def current_build_url
  end

  # Returns a string identifying the path associated with the object.
  # ActionPack uses this to find a suitable partial to represent the object.
  # To know more about this method, see:
  #   http://api.rubyonrails.org/classes/ActiveModel/Conversion.html#method-i-to_partial_path
  def to_partial_path
    "projects/project"
  end
end