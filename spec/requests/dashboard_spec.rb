require 'spec_helper'

feature "dashboard" do
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

    context "with no building projects" do
      let!(:project) { FactoryGirl.create(:project) }

      before do
        visit root_path
      end

      it 'should display a publish date in the project tile' do
        page.should have_selector("#project_#{project.id} .publish-date")
      end

      it 'should not display the building indicator in the project tile' do
        page.should_not have_selector("#project_#{project.id} .building-indicator")
      end
    end

    context "with a building project" do
      let!(:project) { FactoryGirl.create(:project, :building => true) }

      before do
        visit root_path
      end

      it 'should add class building to the project li' do
        page.should have_selector("li.building")
      end
    end

  end

  context "project list as JSON" do
    let!(:project) { FactoryGirl.create(:project, code: "MyCode") }

    before do
      visit root_path(:format => 'json')
    end

    scenario "user sees a JSON collection of current build statuses" do
      builds = JSON.parse(page.source)
      builds.should include(JSON.parse(project.to_json))
    end
  end

  context "the build RSS feed" do
    let!(:project) { FactoryGirl.create(:project, code: "MyCode", statuses: [ProjectStatus.new(build_id: 1)]) }
    before { visit '/builds.rss' }

    scenario "user sees an RSS feed of current builds statuses" do
      page.should have_css("item guid")
      page.should have_content("MyCode")
    end
  end

  context "viewing tracker velocity" do
    scenario "user sees indicator when unable to connect to tracker" do
      FactoryGirl.create(:project_with_tracker_integration, tracker_online: false)
      visit root_path
      page.should have_content("No Connection")
      page.should have_no_content("Velocity")
    end

    scenario "user sees current velocity number when velocity history present" do
      FactoryGirl.create(:project_with_tracker_integration, last_ten_velocities: [3, 2], current_velocity: 1)
      visit root_path
      page.should have_content("Velocity 1")
    end

    scenario "user does not see current velocity number when velocity history not present" do
      FactoryGirl.create(:project_with_tracker_integration, last_ten_velocities: [], current_velocity: 1)
      visit root_path
      page.should have_content("Velocity")
      page.should have_no_content("Velocity 1")
    end
  end

  context "graphing iteration points" do
    scenario "user sees a graph when tracker integration enabled" do
      FactoryGirl.create(:project_with_tracker_integration)
      visit root_path
      page.should have_css(".chart")
    end

    scenario "user does not see a graph when tracker integration not enabled" do
      FactoryGirl.create(:project)
      visit root_path
      page.should_not have_css(".chart")
    end
  end

  context "aggregate projects" do
    scenario "user does not see the build history and last build time" do
      FactoryGirl.create(:aggregate_project)
      visit root_path
      within "li.aggregate" do
        page.should_not have_css(".publish-date")
        page.should_not have_css(".history")
        page.should have_content("Aggregate")
      end
    end

    scenario "user sees the projects for an aggregate project" do
      project = FactoryGirl.create(:project)
      aggregate_project = FactoryGirl.create(:aggregate_project, projects: [project])
      visit root_path
      click_on(aggregate_project.code)

      within('li.project') do
        page.should have_content(project.code)
      end
    end
  end
end
