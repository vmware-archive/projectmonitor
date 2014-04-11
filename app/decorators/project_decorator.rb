class ProjectDecorator < Draper::Decorator
  delegate_all

  def css_id
    "#{object.class.base_class.name.underscore}_#{object.id}"
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