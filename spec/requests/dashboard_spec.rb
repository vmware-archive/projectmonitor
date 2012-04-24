require 'spec_helper'

feature "Dashboard" do
  let(:password) { "monkey" }
  let(:user) { FactoryGirl.create(:user, password: password) }
  context "looking at projects" do
    before { visit root_path }
    scenario "user toggles tile layout" do
      page.should have_css("ol.projects.tiles_15")

      click_link "24"
      page.should have_css("ol.projects.tiles_24")

      click_link "48"
      page.should have_css("ol.projects.tiles_48")

      click_link "63"
      page.should have_css("ol.projects.tiles_63")

      click_link "15"
      page.should have_css("ol.projects.tiles_15")
    end
  end

  scenario "user toggles the location view" do
    15.times { FactoryGirl.create(:project, location: "Jamaica") }
    5.times { FactoryGirl.create(:project, location: "New York") }
    5.times { FactoryGirl.create(:project, location: "San Francisco") }
    2.times { FactoryGirl.create(:project) }

    visit root_path

    page.should have_no_content("Jamaica")
    page.should have_no_content("New York")
    page.should have_no_content("San Francisco")

    click_link "locations"

    page.should have_content("Jamaica")
    page.should have_content("New York")
    page.should have_content("San Francisco")

    click_link "48"

    page.should have_no_content("Jamaica")
    page.should have_no_content("New York")
    page.should have_no_content("San Francisco")
  end

  context "the build RSS feed" do
    before { visit '/builds.rss' }

    scenario "user sees an RSS feed of current builds statuses" do
      page.should have_css "item guid"
    end
  end
end
