class ProjectDecorator < ApplicationDecorator

  delegate :to_s, :to => :model

  def as_json(options = {})
    model.as_json(only: :id, methods: :tag_list)
  end

  def css_id
    "#{model.class.base_class.name.underscore}_#{model.id}"
  end

  def css_class
    klass = 'project'
    klass += if red?
      ' failure'
    elsif green?
      ' success'
    else
      ' offline'
    end
    klass += ' aggregate' if respond_to? :projects

    klass
  end

  def time_since_last_build
    return unless published_at = latest_status.try(:published_at)

    since_last_build = Time.now - published_at
    if published_at <= 1.week.ago
      (since_last_build / 1.week).floor.to_s + "w"
    elsif published_at <= 1.day.ago
      (since_last_build / 1.day).floor.to_s + "d"
    elsif published_at <= 1.hour.ago
      (since_last_build / 1.hour).floor.to_s + "h"
    elsif published_at <= 1.minute.ago
      (since_last_build / 1.minute).floor.to_s + "m"
    else
      since_last_build.floor.to_s + "s"
    end
  end

end
