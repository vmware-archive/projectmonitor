require 'spec_helper'

feature "Dashboard" do
  let(:password) { "monkey" }
  let(:user) { FactoryGirl.create(:user, password: password) }

  context "looking at projects" do
    before { visit root_path }

    scenario "user toggles tile layout" do
      page.should have_css(".tiles_15 ol.projects")

      click_link "24"
      page.should have_css(".tiles_24 ol.projects")

      click_link "48"
      page.should have_css(".tiles_48 ol.projects")

      click_link "63"
      page.should have_css(".tiles_63 ol.projects")

      click_link "15"
      page.should have_css(".tiles_15 ol.projects")
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
  end


  context "the build RSS feed" do
    let!(:project) { FactoryGirl.create(:project, code: "MyCode", statuses: [ProjectStatus.new]) }
    before { visit '/builds.rss' }

    scenario "user sees an RSS feed of current builds statuses" do
      page.should have_css("item guid")
      page.should have_content("MyCode")
    end
  end
end
