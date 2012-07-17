require "spec_helper"

feature "Admin Projects" do
  before do
    visit root_path

    click_link "manage projects"

    user = FactoryGirl.create(:user, password: "monkey")

    fill_in "login", with: user.login
    fill_in "password", with: "monkey"

    click_button "Log In"
  end

  scenario "admin creates a project", :js => true do
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

  scenario "admin edits a project", :js => true do
    travis_project = FactoryGirl.create(:travis_project, account: "pivotal", project: "projectmonitor", tracker_project_id: "123", tracker_auth_token: "garbage")

    visit "/projects/#{travis_project.id}/edit"

    new_account = "pivotal2"
    new_project = "projectmonitor2"

    fill_in "Account", :with => new_account
    fill_in "Project", :with => new_project

    click_button "Update"

    page.should have_content("Project was successfully updated")

    travis_project.reload
    travis_project.account.should == new_account
    travis_project.project.should == new_project
  end
end
