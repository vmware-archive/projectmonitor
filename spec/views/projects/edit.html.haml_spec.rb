require 'spec_helper'

describe 'projects/edit', :type => :view do
  let(:creator) { nil }
  let(:project) { create(:travis_project, creator: creator) }

  before(:each) do
    assign(:project, project)
    render
  end

  describe "information about project creator" do
    context "when the creator is missing" do
      it "does not include creator's information" do
        expect(page).to have_no_content "Creator"
      end
    end

    context "when the creator is present" do
      let(:creator) { create(:user) }

      it "has creator's name & email" do
        expect(page).to have_content project.creator.name
        expect(page).to have_content project.creator.email
      end
    end
  end

  describe "error messages" do
    it "should not be visible when the page is first rendered" do
      expect(rendered.present?).to be true # detect false positives if page is blank
      expect(page).to_not have_css("#errorExplanation")
    end

    context "for an invalid project" do
      let(:project) do
        project = create(:travis_project)
        project.name = ''
        project.valid? # ensure errors are present, mimic the controller Update action validation
        project
      end

      it "should be visible" do
        expect(page.find('#errorExplanation')).to have_css("li", count: project.errors.count)
        expect(page.find('#errorExplanation')).to have_css("li", text: project.errors.full_messages.first)
      end
    end
  end

  describe 'project-specific attributes' do
    it 'should the specific attributes for a given project type' do
      TravisProject.project_specific_attributes.each do |attribute|
        expect(page.find('#TravisProject')).to have_css("#project_#{attribute}")
      end
    end

    it 'should not include attributes specific to other projects' do
      all_attributes = ProjectsHelper::PROJECT_TYPE_NAMES.collect(&:project_specific_attributes).flatten.uniq
      unexpected_attributes = all_attributes - TravisProject.project_specific_attributes

      unexpected_attributes.each do |unexpected_attribute|
        expect(page.find('#TravisProject')).not_to have_css("#project_#{unexpected_attribute}")
      end
    end

    describe 'visibility' do
      it 'should show attributes specific to the current project type' do
        expect(page.find("#TravisProject")).not_to have_class('hide')
        expect(page.find('#build_setup #branch_name')).not_to have_class('hide')
      end

      it 'should hide attributes specific to other project types' do
        expect(page.find('#CruiseControlProject')).to have_class('hide')
        expect(page.find('#JenkinsProject')).to have_class('hide')
        expect(page.find('#TeamCityRestProject')).to have_class('hide')
        expect(page.find('#TeamCityProject')).to have_class('hide')
        expect(page.find('#SemaphoreProject')).to have_class('hide')
      end
    end

    describe 'a help block' do
      describe 'for the Travis Pro auth token' do
        it 'is shown for a Travis Pro project' do
          expect(page.find('#TravisProProject')).to have_css(".help-block", text: "Find this on your Travis-CI.com profile")
        end

        it 'is not shown for a CircleCI project' do
          expect(page.find('#CircleCiProject')).not_to have_css('.help-block')
        end
      end

      describe 'for specifying the project name' do
        it 'is shown for a Tddium project' do
          expect(page.find('#TddiumProject')).to have_css(".help-block", text: "Project name format: 'repo_name (branch_name)'")
        end

        it 'is not shown for a Jenkins project' do
          expect(page.find('#JenkinsProject')).not_to have_css('.help-block')
        end
      end
    end

  end
end
