module ProjectsHelper

  PROJECT_META = YAML.load(File.read(Rails.root.join('config', 'project-meta.yml'))).with_indifferent_access

  PROJECT_TYPE_NAMES = PROJECT_META[:types].map(&:constantize)

  def project_types
    [['', '']] + PROJECT_TYPE_NAMES.map do |type_class|
      [t("project_types.#{type_class.name.underscore}"), type_class.name]
    end
  end

  def project_webhooks_url(project)
    if project.guid.present?
      "Your webhooks URL is " + project_status_url(project.guid).to_s
    else
      unless project.new_record?
        project.generate_guid
        project.save!
      end
      ""
    end
  end

  def project_refreshed_at(project)
    if (refreshed_at = project.last_refreshed_at).present?
      t('helpers.projects.last_refreshed_at', time: l(refreshed_at, format: :short), date: l(refreshed_at.to_date, format: :short))
    end
  end

  def project_latest_error(project)
    project.payload_log_entries.first.try { |l| "#{l.error_type}: '#{l.error_text}'" }
  end

  def project_last_status_text(project)
    if latest = project.payload_log_entries.latest
      if project.enabled
        latest.status || "Unknown Status"
      else
        "disabled"
      end
    else
      "none"
    end.titleize
  end

  def project_last_status(project)
    if latest = project.payload_log_entries.latest
      if project.enabled?
        content_tag(:span, class: "last_status #{latest.status}") do
          color_class = {
            'successful' => 'text-success',
            'failed'    => 'text-danger'
          }[latest.status]
          content_tag(:a, latest, href: project_payload_log_entries_path(project), class: color_class)
        end
      else
        content_tag(:span, class: "last_status #{latest.status}") do
          content_tag(:p, "Disabled")
        end
      end
    else
      "None"
    end
  end

  ProjectAttribute = Struct.new(:name, :label, :tooltip)

  def project_specific_attributes_for(project_class)
    project_key = project_class.name.underscore

    project_class.project_specific_attributes.each_with_object({}) do |field_name, hash|
      label   = PROJECT_META[:labels].try(:[], field_name).try(:[], project_key)
      tooltip = PROJECT_META[:tooltips].try(:[], field_name).try(:[], project_key)

      hash[field_name.to_sym] = ProjectAttribute.new(field_name, label, tooltip)
    end
  end
end
