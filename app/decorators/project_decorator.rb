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
    elsif yellow?
      ' indeterminate'
    else
      ' offline'
    end
    klass += ' aggregate' if respond_to? :projects

    klass
  end
end
