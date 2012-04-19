require 'spec_helper'

feature "Dashboard" do
  let(:password) { "monkey" }
  let(:user) { FactoryGirl.create(:user, password: password) }
  before { visit root_path }
  scenario "user toggles tile layout" do
    page.should have_css("ol.projects.tiles_15")

    click_link "24"
    page.should have_css("ol.projects.tiles_24")

    click_link "48"
    page.should have_css("ol.projects.tiles_48")

    click_link "15"
    page.should have_css("ol.projects.tiles_15")
  end
end
