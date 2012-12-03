require 'spec_helper'

feature "home", js: true do
  let!(:project) { FactoryGirl.create(:project) }

  it "should render tile collection" do
    visit "/home"
    page.should have_selector(".tiles")
    page.should have_selector(".tile")
  end
end
