module ProjectsHelper
  PROJECT_TYPE_NAMES = [CruiseControlProject, JenkinsProject, TeamCityRestProject, TeamCityProject, TeamCityChainedProject, TravisProject]

  def project_types
    [['', '']] + PROJECT_TYPE_NAMES.map do |type_class|
      [type_class.name.titleize, type_class.name]
    end
  end

end
