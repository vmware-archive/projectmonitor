class ProjectDecorator < ApplicationDecorator
  def css_id
    "#{model.class.base_class.name.underscore}_#{model.id}"
  end

  def css_class
    klass = 'project'
    if red?
      klass += ' failure'
    elsif green?
      klass += ' success'
    else
      klass += ' offline'
    end
    klass += ' aggregate' if respond_to? :projects

    klass
  end

  def time_since_last_build
    return unless published_at = latest_status.try(:published_at)

    if published_at <= 1.week.ago
      ((Time.now - published_at) / (60 * 60 * 24 * 7)).floor.to_s + "w"
    elsif published_at <= 1.day.ago
      ((Time.now - published_at) / (60 * 60 * 24)).floor.to_s + "d"
    elsif published_at <= 1.hour.ago
      ((Time.now - published_at) / (60 * 60)).floor.to_s + "h"
    elsif published_at <= 1.minute.ago
      ((Time.now - published_at) / 60).floor.to_s + "m"
    else
      (Time.now - published_at).floor.to_s + "s"
    end
  end

end
