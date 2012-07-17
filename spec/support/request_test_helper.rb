module RequestTestHelper
  def log_in
    visit "/"

    click_link "manage projects"

    user = FactoryGirl.create(:user, password: "monkey")

    fill_in "login", with: user.login
    fill_in "password", with: "monkey"

    click_button "Log In"
  end
end

RSpec.configure do |config|
  config.include RequestTestHelper, :type => :request
end
