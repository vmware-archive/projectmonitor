require 'spec_helper'

feature "home" do
  context "when project has only build information" do
    let!(:project) { FactoryGirl.create(:project) }

    before do
      project.statuses << FactoryGirl.build(:project_status, success: true, published_at: 5.days.ago)
    end

    it "should render project collection", js: true do
      visit root_path
      page.should have_selector(".statuses .success")

      page.should have_selector(".time-since-last-build", text: project.time_since_last_build)
      page.should have_content(project.code)
    end
  end

  context "aggregate projects" do
    let!(:aggregate) { FactoryGirl.create(:aggregate_project, code: 'GTFO', projects: [project]) }
    let!(:project) { FactoryGirl.create(:travis_project) }

    it "user sees the projects for an aggregate project", js: true do
      visit root_path
      click_on(aggregate.code)

      page.should have_content(project.code)

    end
  end
end
