require 'spec_helper'

feature "home" do
  context "when project has only build information" do
    let!(:project) { FactoryGirl.create(:project) }

    before do
      project.statuses << FactoryGirl.build(:project_status, success: true, published_at: 5.days.ago)
    end

    it "should render project collection", js: true do
      visit "/"
      page.should have_selector(".projects")
      page.should have_selector(".project")
      page.should have_selector(".code", text: project.code)
      page.should have_selector(".time-since-last-build", text: project.time_since_last_build)
      page.should have_selector(".statuses .success")
    end
  end

  context "when project has build and tracker information" do
    let!(:project) { FactoryGirl.create(:project_with_tracker_integration) }

    before do
      project.statuses << FactoryGirl.build(:project_status, success: true, published_at: 5.days.ago)
    end

    it "should render project collection", js: true do
      visit "/"
      page.should have_selector(".projects")
      page.should have_selector(".project")
      page.should have_selector(".code", text: project.code)
      page.should have_selector(".time-since-last-build", text: project.time_since_last_build)
      page.should have_selector(".statuses .success")
    end
  end

  context "viewing tracker velocity" do
    context "when unable to connect to tracker" do
      let!(:project) { FactoryGirl.create(:project_with_tracker_integration, tracker_online: false) }

      it "shows no connection", js: true do
        visit root_path
        page.should have_content("No Connection")
      end
    end

    context "when velocity history present" do
      let!(:project) { FactoryGirl.create(:project_with_tracker_integration, current_velocity: 1) }

      it "shows current velocity number and history graph", js: true do
        visit root_path

        within('.current-velocity') do
          page.should have_content("1")
        end
        within('.velocities') do
          page.should have_css("span")
        end

        page.should have_content(project.code) # this line insures that capybara waits for the last ajax poll to finish
                                               # before truncating the DB (which leads to nasty, flaky false negatives)
      end
    end

    context "when velocity history is not preset" do
      let!(:project) { FactoryGirl.create(:project_with_tracker_integration, last_ten_velocities: [], current_velocity: 1) }

      it "does not show history graph", js: true do
        visit root_path

        within('.current-velocity') do
          page.should have_content("1")
        end
        within('.velocities') do
          page.should_not have_css("span")
        end

        page.should have_content(project.code) # this line insures that capybara waits for the last ajax poll to finish
                                               # before truncating the DB (which leads to nasty, flaky false negatives)
      end
    end
  end

  context "aggregate projects" do
    let!(:aggregate) { FactoryGirl.create(:aggregate_project, code: 'GTFO', projects: [project]) }
    let!(:project) { FactoryGirl.create(:travis_project) }

    it "user sees the projects for an aggregate project", js: true do
      visit root_path
      click_on(aggregate.code)

      within('h1.code') do
        page.should have_content(project.code)
      end

      page.should have_content(project.code) # this line insures that capybara waits for the last ajax poll to finish
                                             # before truncating the DB (which leads to nasty, flaky false negatives)
    end
  end
end
