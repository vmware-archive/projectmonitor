require 'spec_helper'

describe "users/new", :type => :view do
  describe "error messages" do
    it "should not be visible when the page is first rendered" do
      assign :user, User.new
      render

      expect(rendered.present?).to be true # detect false positives if page is blank
      expect(page).to_not have_css("#errorExplanation")
    end

    it "should be visible when the new user record is invalid" do
      user = User.new email: ""
      user.valid? # ensure errors are present, mimic the controller Create action validation
      assign :user, user
      render

      expect(page.find('#errorExplanation')).to have_css("li", count: user.errors.count)
      expect(page.find('#errorExplanation')).to have_css("li", text: user.errors.full_messages.first)
    end
  end
end
