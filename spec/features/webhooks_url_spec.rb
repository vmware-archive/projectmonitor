# encoding: UTF-8
require 'spec_helper'

feature "webhooks url" do
  let!(:project) { FactoryGirl.build(:project, webhooks_enabled: true) }
  let!(:user) { FactoryGirl.create(:user, password: "jeffjeff", password_confirmation: "jeffjeff") }

  before do
    Project.destroy_all
    project.save!
    log_in(user, "jeffjeff")
    visit "/"
    click_link "manage projects"
  end

  scenario "when webhooks are enabled show thatL" do
    project.guid.should_not be_nil
    page.should_not have_content(project.id)
    page.should have_content(project.name)
    within ".webhooks" do
      page.should have_content("✓")
    end
  end

end
