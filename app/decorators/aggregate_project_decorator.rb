class AggregateProjectDecorator < Draper::Decorator
  delegate_all

  def css_id
    "#{object.class.base_class.name.underscore}_#{object.id}"
  end

  def status_in_words
    object.state.to_s
  end

  def css_class
    "project #{status_in_words} aggregate"
  end

end
