module ProjectsHelper
  PROJECT_TYPE_NAMES = [CruiseControlProject, JenkinsProject, TeamCityRestProject, TeamCityChainedProject, TeamCityProject, TravisProject]

  def project_types
    [['', '']] + PROJECT_TYPE_NAMES.map do |type_class|
      [t("project_types.#{type_class.name.underscore}"), type_class.name]
    end
  end

end
