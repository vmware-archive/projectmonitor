require 'spec_helper'

feature "Authentication" do
  let(:password) { "monkey" }
  let(:user) { FactoryGirl.create(:user, password: password) }
  before { visit root_path }
  scenario "user logs in and logs out" do
    click_link "manage projects"

    fill_in "login", with: user.login
    fill_in "password", with: password

    click_button "Log In"

    page.should have_content("Logged in successfully")

    visit root_path

    click_link "log out"

    page.should_not have_content "log out"
  end
end
