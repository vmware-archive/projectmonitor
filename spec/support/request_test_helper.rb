module RequestTestHelper
  def log_in(user, password)
    visit "/users/sign_in"

    fill_in "user_login", with: user.login
    fill_in "user_password", with: password

    click_button "Sign in"
  end
end

RSpec.configure do |config|
  config.include RequestTestHelper, type: :feature
end
