require 'spec_helper'

feature "webhooks url" do
  let!(:project) { FactoryGirl.build(:project, webhooks_enabled: true) }

  before do
    Project.destroy_all
    project.save!
    log_in
    visit "/"
    click_link "manage projects"
  end

  scenario "webhooks URL with random GUID not ID" do
    project.guid.should_not be_nil
    page.should_not have_content(project.id)
    page.should have_content(project.guid)
  end

end
