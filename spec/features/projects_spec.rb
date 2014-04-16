require "spec_helper"

feature "projects" do
  let!(:project) { FactoryGirl.create(:travis_project, travis_github_account: "pivotal", travis_repository: "projectmonitor") }
  let!(:user) { FactoryGirl.create(:user, password: "jeffjeff", password_confirmation: "jeffjeff") }

  before do
    log_in(user, "jeffjeff")
    click_on("manage projects")
  end

  scenario "admin creates a Travis project", js: true do
    click_on "Add Project"

    select "Travis Project", from: "Project Type"
    choose "project_webhooks_enabled_false"
    fill_in "project[name]", with: "Project Monitor"

    click_on "Create"

    page.should have_content("Travis github account can't be blank")
    page.should have_content("Travis repository can't be blank")

    fill_in "Github Account", with: "pivotal"
    fill_in "Repository", with: "projectmonitor"

    click_on "Create"

    page.should have_content("Project was successfully created")
  end

  scenario "admin creates a Travis Pro project", js: true do
    click_on "Add Project"

    select "Travis Pro Project", from: "Project Type"
    choose "project_webhooks_enabled_false"
    fill_in "project[name]", with: "Project Monitor"
    fill_in "Github Account", with: "pivotal"
    fill_in "Repository", with: "projectmonitor"
    fill_in "Travis Pro Token", with: "travisprotoken"

    click_on "Create"

    page.should have_content("Project was successfully created")
  end

  scenario "admin edits a project", js: true do
    within "#project-#{project.id}" do
      click_link "Edit"
    end

    new_account = "pivotal2"
    new_project = "projectmonitor2"

    fill_in "Github Account", with: new_account
    fill_in "Repository", with: new_project

    click_button "Update"

    page.should have_content("Project was successfully updated")

    project.reload
    project.travis_github_account.should == new_account
    project.travis_repository.should == new_project
  end
end
