require 'spec_helper'

feature "home" do
  context "when project has only build information" do
    let!(:project) { create(:project) }

    before do
      project.statuses << build(:project_status, success: true, published_at: 5.days.ago)
    end

    it "should render project collection", js: true do
      visit root_path

      expect(page).to have_selector(".statuses .success")
      expect(page).to have_selector(".time-since-last-build", text: "5d")
      expect(page).to have_content(project.code)
    end

    it "should refresh the project collection", js: true do
      visit root_path

      expect(page).to_not have_selector(".time-since-last-build", text: "4d")

      project.statuses << FactoryGirl.build(:project_status, success: true, published_at: 4.days.ago)
      page.execute_script('window.ProjectMonitor.collectionData.projects.fetch()')

      expect(page).to have_selector(".time-since-last-build", text: "4d")
    end
  end

  context "aggregate projects" do
    let!(:aggregate) { create(:aggregate_project, code: 'GTFO', projects: [project]) }
    let!(:project) { create(:travis_project) }
    let!(:emoji_project) { create(:travis_project, code: "\u{1F4A9}") }

    it "user sees the projects for an aggregate project", js: true do
      visit root_path
      click_on(aggregate.code)

      expect(page).to have_content(project.code)
    end

    it "renders emoji correctly", js: true do
      visit root_path

      expect(page).to have_content("\u{1F4A9}")
    end
  end
end
