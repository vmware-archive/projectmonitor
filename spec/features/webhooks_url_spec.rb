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
    expect(project.guid).not_to be_nil
    expect(page).not_to have_content(project.id)
    expect(page).to have_content(project.name)
    within ".webhooks" do
      expect(page).to have_content("✓")
    end
  end

end
