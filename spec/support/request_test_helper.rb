module RequestTestHelper
  def log_in
    visit "/"

    click_link "manage projects"

    user = FactoryGirl.create(:user, password: "monkey")

    fill_in "user_login", with: user.login
    fill_in "user_password", with: "monkey"

    click_button "Sign in"
  end
end

RSpec.configure do |config|
  config.include RequestTestHelper, :type => :feature
end
