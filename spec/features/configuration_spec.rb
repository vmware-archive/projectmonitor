require 'spec_helper'

feature 'configuration export' do
  let!(:user) { create(:user, password: "jeffjeff") }

  before do
    log_in(user, "jeffjeff")
  end

  scenario 'obtain a configuration export' do
    create(:aggregate_project)
    project = create(:jenkins_project)

    visit configuration_path(format: 'txt')

    configuration = YAML.load page.source
    expect(configuration).to have_key('aggregate_projects')
    expect(configuration).to have_key('projects')
    project_names = configuration['projects'].map {|project| project['name']}
    expect(project_names).to include(project.name)
  end

end
