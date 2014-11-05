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
        expect(page).to have_css("#errorExplanation")
        expect(page).to have_css("#errorExplanation li", count: project.errors.count)
        expect(page).to have_css("#errorExplanation li", text: project.errors.full_messages.first)
      end
    end
  end

  describe 'project-specific attributes' do
    it 'should the specific attributes for a given project type' do
      TravisProject.project_specific_attributes.each do |attribute|
        expect(page).to have_css("#TravisProject #project_#{attribute}")
      end
    end

    it 'should not include attributes specific to other projects' do
      all_attributes = ProjectsHelper::PROJECT_TYPE_NAMES.collect(&:project_specific_attributes).flatten.uniq
      unexpected_attributes = all_attributes - TravisProject.project_specific_attributes

      unexpected_attributes.each do |attribute|
        expect(page).not_to have_css("#TravisProject #project_#{attribute}")
      end
    end

    describe 'visibility' do
      it 'should show attributes specific to the current project type' do
        expect(page).to     have_css("##{project.class}")
        expect(page).not_to have_css("##{project.class}.hide")
        expect(page).to     have_css('#build_setup #branch_name')
        expect(page).not_to have_css('#build_setup #branch_name.hide')
      end

      it 'should hide attributes specific to other project types' do
        expect(page).to have_css('#CruiseControlProject.hide')
        expect(page).to have_css('#JenkinsProject.hide')
        expect(page).to have_css('#TeamCityRestProject.hide')
        expect(page).to have_css('#TeamCityProject.hide')
        expect(page).to have_css('#SemaphoreProject.hide')
      end
    end

    describe 'a help block' do
      describe 'for the Travis Pro auth token' do
        it 'is shown for a Travis Pro project' do
          expect(page).to have_css(".project-attributes#TravisProProject .help-block", text: "Find this on your Travis-CI.com profile")
        end

        it 'is not shown for a CircleCI project' do
          expect(page).to have_css('.project-attributes#CircleCiProject')
          expect(page).not_to have_css('.project-attributes#CircleCiProject .help-block')
        end
      end

      describe 'for specifying the project name' do
        it 'is shown for a Tddium project' do
          expect(page).to have_css(".project-attributes#TddiumProject .help-block", text: "Project name format: 'repo_name (branch_name)'")
        end

        it 'is not shown for a Jenkins project' do
          expect(page).to have_css('.project-attributes#JenkinsProject')
          expect(page).not_to have_css('.project-attributes#JenkinsProject .help-block')
        end
      end
    end

  end
end
