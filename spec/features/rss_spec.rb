require 'spec_helper'

feature "rss" do
  context "the build RSS feed" do
    let!(:project) { FactoryGirl.create(:project, code: "MyCode", statuses: [ProjectStatus.new(build_id: 1)]) }
    before { visit '/builds.rss' }

    scenario "user sees an RSS feed of current builds statuses" do
      page.should have_css("item guid", :text => "MyCode")
    end
  end
end
