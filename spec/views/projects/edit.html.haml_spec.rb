require 'spec_helper'

describe "projects/new" do

  before do
    @project = FactoryGirl.build(:travis_project)
  end

  it 'has a visible fieldset for travis project fields' do
    render
    rendered.should have_css('fieldset#TravisProject')
    rendered.should_not have_css('fieldset#TravisProject.hide')
  end

  it 'should render the alternative project specific fields as hidden' do
    render
    rendered.should have_css('fieldset#CruiseControlProject.hide')
    rendered.should have_css('fieldset#JenkinsProject.hide')
    rendered.should have_css('fieldset#TeamCityRestProject.hide')
    rendered.should have_css('fieldset#TeamCityProject.hide')
    rendered.should have_css('fieldset#TeamCityChainedProject.hide')
  end

end

