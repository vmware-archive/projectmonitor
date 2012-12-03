require 'spec_helper'

feature "home", js: true do
  let!(:project) { FactoryGirl.create(:project) }

  before do
    project.statuses << FactoryGirl.build(:project_status, success: true, published_at: 5.days.ago)
  end

  it "should render project collection" do
    visit "/home"
    page.should have_selector(".projects")
    page.should have_selector(".project")
    page.should have_selector(".code", text: project.code)
    page.should have_selector(".time-since-last-build", text: project.time_since_last_build)
    page.should have_selector(".statuses .success")
  end
end
