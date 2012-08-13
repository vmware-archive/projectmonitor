module ProjectsHelper
  PROJECT_TYPE_NAMES = [CruiseControlProject, JenkinsProject, TeamCityRestProject, TeamCityChainedProject, TeamCityProject, TravisProject]

  def project_types
    [['', '']] + PROJECT_TYPE_NAMES.map do |type_class|
      [t("project_types.#{type_class.name.underscore}"), type_class.name]
    end
  end

  def project_webhooks_url(project)
    if project.guid.present?
      original_url = project_status_url(project)
      guid_url = original_url.gsub(project.id.to_s, project.guid.to_s)
    else
      "not yet configured"
    end
  end
end
