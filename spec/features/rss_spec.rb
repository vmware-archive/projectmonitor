require 'spec_helper'

feature "rss" do
  context "the build RSS feed" do
    let!(:project) { create(:project, code: "MyCode", statuses: [ProjectStatus.new(build_id: 1)]) }
    before { visit '/builds.rss' }

    scenario "user sees an RSS feed of current builds statuses" do
      expect(page).to have_css("item guid")
      expect(page).to have_content("MyCode")
    end
  end
end
