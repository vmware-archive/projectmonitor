require 'spec_helper'

feature 'aggregate projects' do
  let!(:aggregate_project) { FactoryGirl.create(:aggregate_project) }

  before do
    log_in
    visit "/"
    click_link "manage projects"
  end

  scenario 'admin creates an aggregate project' do
    click_link "Add Aggregate Project"

    click_button "Create"

    page.should have_content("Name can't be blank")

    fill_in "Name", with: "Aggregate Test"

    click_button "Create"

    page.should have_content('Aggregate project was successfully created.')
    page.should have_content("Aggregate Test")
  end

  scenario 'admin edits an aggregate project' do
    within "#aggregate-project-#{aggregate_project.id}" do
      click_link "Edit"
    end

    fill_in "Name", with: "Updated Name"

    click_button "Update"

    page.should have_content('Aggregate project was successfully updated.')
    page.should have_content('Updated Name')
  end
end
