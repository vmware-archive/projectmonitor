module ProjectsHelper
  PROJECT_TYPE_NAMES = [CruiseControlProject,
                        JenkinsProject,
                        SemaphoreProject,
                        TeamCityRestProject,
                        TeamCityProject,
                        TravisProject,
                        TddiumProject,
                        CircleCiProject]

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

  def project_status_link(project)
    if (current_build_url = project.current_build_url).present?
      link_to(project.code, current_build_url)
    else
      project.code
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

  def project_last_status(project)
    if latest = project.payload_log_entries.latest
      if project.enabled?
        content_tag(:span, class: "last_status #{latest.status}") do
          content_tag(:a, latest, href: project_payload_log_entries_path(project))
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
end
