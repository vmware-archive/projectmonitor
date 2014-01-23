require 'spec_helper'

describe 'projects/edit' do

  describe "information about project creator" do
    context "when the creator is missing" do
      it "does not include creator's information" do
        project = FactoryGirl.create(:travis_project, creator: nil)
        assign(:project, project)
        render
        page.should have_no_content "Creator"
      end
    end

    context "when the creator is present" do
      let(:project) { FactoryGirl.create(:travis_project, creator: creator) }
      let(:creator) { FactoryGirl.create(:user) }

      before do
        assign(:project, project)
        render
      end

      it "has creator's name" do
        page.should have_content project.creator.name
      end

      it "has creator's email" do
        page.should have_content project.creator.email
      end
    end
  end

  context 'Travis Project' do
    let(:project) { FactoryGirl.create(:travis_project) }

    before do
      assign(:project, project)
      render
    end

    it 'has a visible fieldset for travis project fields' do
      page.should have_css('.project-attributes#TravisProject')
      page.should_not have_css('.project-attributes#TravisProject.hide')
      page.should_not have_css('fieldset#build_setup #branch_name.hide')
    end

    it 'should render the alternative project specific fields as hidden' do
      page.should have_css('.project-attributes#CruiseControlProject.hide')
      page.should have_css('.project-attributes#JenkinsProject.hide')
      page.should have_css('.project-attributes#TeamCityRestProject.hide')
      page.should have_css('.project-attributes#TeamCityProject.hide')
      page.should have_css('.project-attributes#SemaphoreProject.hide')
    end
  end
end
