require 'spec_helper'

feature 'configuration export' do
  let(:archived_project_name) { Faker::Name.name }
  let!(:user) { FactoryGirl.create(:user, password: "jeffjeff", password_confirmation: "jeffjeff") }

  before do
    log_in(user, "jeffjeff")
  end

  scenario 'obtain a configuration export' do
    FactoryGirl.create(:aggregate_project)
    FactoryGirl.create(:jenkins_project, name: archived_project_name)

    visit configuration_path(format: 'txt')

    configuration = YAML.load page.source
    expect(configuration).to have_key('aggregate_projects')
    expect(configuration).to have_key('projects')
    project_names = configuration['projects'].map {|project| project['name']}
    expect(project_names).to include(archived_project_name)
  end

end
