require 'spec_helper'

feature "home" do
  let!(:aggregate_project) { FactoryGirl.create(:aggregate_project) }

  before { visit home_path }

  it "should display aggregate project" do
    page.should have_selector("article[@data-project-id='#{aggregate_project.id}']")
  end
end
