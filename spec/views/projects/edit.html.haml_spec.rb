require 'spec_helper'

describe 'projects/edit' do
  context 'Travis Project' do
    let(:project) { FactoryGirl.create(:travis_project) }

    before do
      assign(:project, project)
      render
    end

    it 'has a visible fieldset for travis project fields' do
      rendered.should have_css('fieldset#TravisProject')
      rendered.should_not have_css('fieldset#TravisProject.hide')
      rendered.should_not have_css('fieldset#build_setup #branch_name.hide')
    end

    it 'should render the alternative project specific fields as hidden' do
      rendered.should have_css('fieldset#CruiseControlProject.hide')
      rendered.should have_css('fieldset#JenkinsProject.hide')
      rendered.should have_css('fieldset#TeamCityRestProject.hide')
      rendered.should have_css('fieldset#TeamCityProject.hide')
      rendered.should have_css('fieldset#SemaphoreProject.hide')
    end
  end
end
