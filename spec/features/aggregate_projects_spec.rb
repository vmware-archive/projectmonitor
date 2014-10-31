require 'spec_helper'

feature 'aggregate projects' do
  let!(:aggregate_project) { create(:aggregate_project) }
  let!(:user) { create(:user, password: "jeffjeff", password_confirmation: "jeffjeff") }

  context "manage projects" do
    before do
      log_in(user, "jeffjeff")
      visit "/"
      click_link "manage projects"
    end

    scenario 'admin creates an aggregate project' do
      click_link "Add Aggregate Project"

      click_button "Create"

      expect(page).to have_content("Name can't be blank")

      fill_in "Name", with: "Aggregate Test"

      click_button "Create"

      expect(page).to have_content('Aggregate project was successfully created.')
      expect(page).to have_content("Aggregate Test")
    end

    scenario 'admin edits an aggregate project' do
      within "#aggregate-project-#{aggregate_project.id}" do
        click_link "Edit"
      end

      fill_in "Name", with: "Updated Name"

      click_button "Update"

      expect(page).to have_content('Aggregate project was successfully updated.')
      expect(page).to have_content('Updated Name')
    end
  end
end
