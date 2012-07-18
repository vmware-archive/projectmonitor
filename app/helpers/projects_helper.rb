module ProjectsHelper

  def project_types
    [['', '']]  +
    [CruiseControlProject, JenkinsProject, TeamCityRestProject, TeamCityProject, TeamCityChainedProject, TravisProject].map do |type_class|
      [type_class.name.titleize, type_class.name, {'data-feed-url-fields' => type_class.feed_url_fields.join(',')}]
    end
  end

end
