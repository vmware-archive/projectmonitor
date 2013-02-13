require 'spec_helper'

feature "dashboard" do
  context "the build RSS feed" do
    let!(:project) { FactoryGirl.create(:project, code: "MyCode", statuses: [ProjectStatus.new(build_id: 1)]) }
    before { visit '/builds.rss' }

    scenario "user sees an RSS feed of current builds statuses" do
      page.should have_css("item guid")
      page.should have_content("MyCode")
    end
  end

  context "viewing tracker velocity", js: true do
    scenario "user sees indicator when unable to connect to tracker" do
      FactoryGirl.create(:project_with_tracker_integration, tracker_online: false)
      visit root_path
      page.should have_content("No Connection")
    end

    scenario "user sees current velocity number and history graph when velocity history present" do
      FactoryGirl.create(:project_with_tracker_integration, last_ten_velocities: [3, 2], current_velocity: 1)
      visit root_path

      within('.current-velocity') do
        page.should have_content("1")
      end
      within('.velocities') do
        page.should have_css("span")
      end
    end

    scenario "user does not see history graph when velocity history not present" do
      FactoryGirl.create(:project_with_tracker_integration, last_ten_velocities: [], current_velocity: 1)
      visit root_path

      within('.current-velocity') do
        page.should have_content("1")
      end
      within('.velocities') do
        page.should_not have_css("span")
      end
    end
  end

  context "aggregate projects" do
    scenario "user does not see the build history and last build time", js: true do
      AggregateProject.destroy_all
      aggregate = FactoryGirl.create(:aggregate_project_with_project, code: 'GTFO')
      visit root_path
      within "article.aggregate" do
        page.should_not have_css(".publish-date")
        page.should_not have_css(".history")
        page.should have_content(aggregate.code)
      end
    end

    scenario "user sees the projects for an aggregate project", js: true do
      project = FactoryGirl.create(:travis_project)
      aggregate_project = FactoryGirl.create(:aggregate_project, projects: [project])
      visit root_path
      click_on(aggregate_project.code)

      within('h1.code') do
        page.should have_content(project.code)
      end
    end
  end
end
