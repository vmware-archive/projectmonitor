require 'spec_helper'

describe 'projects/edit', :type => :view do
  let(:creator) { nil }
  let(:project) { FactoryGirl.create(:travis_project, creator: creator) }

  before(:each) { assign(:project, project) }

  describe "information about project creator" do
    before(:each) { render }

    context "when the creator is missing" do
      it "does not include creator's information" do
        expect(page).to have_no_content "Creator"
      end
    end

    context "when the creator is present" do
      let(:creator) { FactoryGirl.create(:user) }

      it "has creator's name & email" do
        expect(page).to have_content project.creator.name
        expect(page).to have_content project.creator.email
      end
    end
  end

  describe "error messages" do
    it "should not be visible when the page is first rendered" do
      render
      expect(rendered.present?).to be true # detect false positives if page is blank
      expect(page).to_not have_css("#errorExplanation")
    end

    it "should be visible when the project record is invalid" do
      project.name = ""
      project.valid? # ensure errors are present, mimic the controller Update action validation
      render

      expect(page).to have_css("#errorExplanation")
      expect(page).to have_css("#errorExplanation li", count: project.errors.count)
      expect(page).to have_css("#errorExplanation li", text: project.errors.full_messages.first)
    end
  end

  context 'Travis Project' do
    let(:project) { FactoryGirl.create(:travis_project) }

    before(:each) { render }

    it 'has a visible fieldset for travis project fields' do
      expect(page).to have_css('.project-attributes#TravisProject')
      expect(page).not_to have_css('.project-attributes#TravisProject.hide')
      expect(page).not_to have_css('fieldset#build_setup #branch_name.hide')
    end

    it 'should render the alternative project specific fields as hidden' do
      expect(page).to have_css('.project-attributes#CruiseControlProject.hide')
      expect(page).to have_css('.project-attributes#JenkinsProject.hide')
      expect(page).to have_css('.project-attributes#TeamCityRestProject.hide')
      expect(page).to have_css('.project-attributes#TeamCityProject.hide')
      expect(page).to have_css('.project-attributes#SemaphoreProject.hide')
    end
  end
end
