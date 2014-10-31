require 'spec_helper'

feature "authentication" do
  let(:password) { "monkey" }
  let(:user) { create(:user, password: password) }

  before { visit root_path }

  scenario "user logs in and logs out" do
    click_link "manage projects"

    fill_in "user_login", with: user.login
    fill_in "user_password", with: password

    click_button "Sign in"

    expect(page).to have_content("Signed in successfully")

    visit root_path

    click_link "log out"

    expect(page).not_to have_content "log out"
  end

  let(:legacy_user) do
    user = build(:user)
    user.encrypted_password = 'xxx'
    user.save!
    user
  end

  scenario "a user with a legacy password logs in" do
    click_link "manage projects"

    fill_in "user_login", with: legacy_user.login
    fill_in "user_password", with: password

    click_button "Sign in"
    expect(page).to have_content("The system has been upgraded, your password needs to be reset before logging in.")
  end
end
