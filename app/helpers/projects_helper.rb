module ProjectsHelper
  PROJECT_TYPE_NAMES = [CruiseControlProject,
                        JenkinsProject,
                        SemaphoreProject,
                        TeamCityRestProject,
                        TeamCityProject,
                        TravisProject]

  def project_types
    [['', '']] + PROJECT_TYPE_NAMES.map do |type_class|
      [t("project_types.#{type_class.name.underscore}"), type_class.name]
    end
  end

  def project_webhooks_url(project)
    if project.guid.present?
      project_status_url(project.guid)
    else
      unless project.new_record?
        project.generate_guid
        project.save!
      end
      "not yet configured"
    end
  end

  def project_status_link(project)
    if (current_build_url = project.current_build_url).present?
      link_to(project.code, current_build_url)
    else
      project.code
    end
  end

end
