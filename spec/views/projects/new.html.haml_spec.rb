require 'spec_helper'

describe "projects/new", :type => :view do

  before(:each) { assign(:project, Project.new) }

  it "should include the server time" do
    allow(Time).to receive(:now).and_return(Time.parse("Wed Oct 26 17:02:10 -0700 2011"))
    render
    expect(page).to have_text("Server time is #{Time.now.to_s}")
  end

  it 'should render all the project specific fields as hidden' do
    render
    expect(page.find('#CruiseControlProject')).to have_class('hide')
    expect(page.find('#JenkinsProject')).to have_class('hide')
    expect(page.find('#TeamCityRestProject')).to have_class('hide')
    expect(page.find('#TeamCityProject')).to have_class('hide')
    expect(page.find('#TravisProject')).to have_class('hide')

    expect(page.find('#build_setup #branch_name')).to have_class('hide')
  end

  describe "error messages" do
    it "should not be visible when the page is first rendered" do
      render
      expect(rendered.present?).to be true # detect false positives if page is blank
      expect(page).to_not have_css("#errorExplanation")
    end

    it "should be visible when the new project record is invalid" do
      project = Project.new name: ""
      # ensure errors are present, mimic the controller Create action validation
      project.valid?
      assign :project, project
      render

      expect(page.find('#errorExplanation')).to have_css("li", count: project.errors.count)
      expect(page.find('#errorExplanation')).to have_css("li", text: project.errors.full_messages.first)
    end
  end

end
