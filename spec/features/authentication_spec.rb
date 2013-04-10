require 'spec_helper'

feature "authentication" do
  let(:password) { "monkey" }
  let(:user) { FactoryGirl.create(:user, password: password) }

  before { visit root_path }

  scenario "user logs in and logs out" do
    click_link "manage projects"

    fill_in "user_login", with: user.login
    fill_in "user_password", with: password

    click_button "Sign in"

    page.should have_content("Signed in successfully")

    visit root_path

    click_link "log out"

    page.should_not have_content "log out"
  end
  
  scenario "user does not see style regressions" do
    click_link "manage projects"
    GreenOnion.skin_visual_and_percentage(current_url, 5)
  end  

  let(:legacy_user) do
    user = FactoryGirl.build(:user)
    user.encrypted_password = 'xxx'
    user.save!
    user
  end

  scenario "a user with a legacy password logs in" do
    click_link "manage projects"

    fill_in "user_login", with: legacy_user.login
    fill_in "user_password", with: password

    click_button "Sign in"
    page.should have_content("The system has been upgraded, your password needs to be reset before logging in.")
  end
end
