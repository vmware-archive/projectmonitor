require "spec_helper"

feature "projects", :js => true do
  let!(:project) { FactoryGirl.create(:travis_project, account: "pivotal", project: "projectmonitor", tracker_project_id: "123", tracker_auth_token: "garbage") }

  before do
    log_in
    visit "/"
    click_link "manage projects"
  end

  scenario "admin creates a project" do
    click_link "Add Project"

    select "Travis Project", :from => "Project Type"
    fill_in "Name", :with => "Project Monitor"
    fill_in "Tracker project id", :with => "123"
    fill_in "Tracker auth token", :with => "abc"

    click_button "Create"

    page.should have_content("Account can't be blank")
    page.should have_content("Project can't be blank")

    fill_in "Account", :with => "pivotal"
    fill_in "Project", :with => "projectmonitor"

    click_button "Create"

    page.should have_content("Project was successfully created")
  end

  scenario "admin edits a project" do
    within "#project-#{project.id}" do
      click_link "Edit"
    end

    new_account = "pivotal2"
    new_project = "projectmonitor2"

    fill_in "Account", :with => new_account
    fill_in "Project", :with => new_project

    click_button "Update"

    page.should have_content("Project was successfully updated")

    project.reload
    project.account.should == new_account
    project.project.should == new_project
  end
end
