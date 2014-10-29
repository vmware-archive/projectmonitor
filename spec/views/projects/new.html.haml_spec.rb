require 'spec_helper'

describe "projects/new", :type => :view do

  before do
    @project = Project.new
  end

  it "should include the server time" do
    allow(Time).to receive(:now).and_return(Time.parse("Wed Oct 26 17:02:10 -0700 2011"))
    render
    expect(rendered).to include("Server time is #{Time.now.to_s}")
  end

  it 'should render all the project specific fields as hidden' do
    render
    expect(rendered).to have_css('.project-attributes#CruiseControlProject.hide')
    expect(rendered).to have_css('.project-attributes#JenkinsProject.hide')
    expect(rendered).to have_css('.project-attributes#TeamCityRestProject.hide')
    expect(rendered).to have_css('.project-attributes#TeamCityProject.hide')
    expect(rendered).to have_css('.project-attributes#TravisProject.hide')

    expect(rendered).to have_css('fieldset#build_setup #branch_name.hide')
  end

end
