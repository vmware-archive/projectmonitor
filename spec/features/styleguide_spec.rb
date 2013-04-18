require 'spec_helper'

feature "styleguide" do
  context "when rendered" do
    let!(:project) { FactoryGirl.create(:project) }

    before do
      project.statuses << FactoryGirl.build(:project_status, success: true, published_at: 5.days.ago)
    end

    it "should not have any style regressions", js: true do
      visit Rails.application.routes.url_helpers.styleguide_path
      GreenOnion.skin_visual_and_percentage(current_url)
    end
  end
end