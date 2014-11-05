module FeatureTestHelper
  def log_in(user, password)
    visit "/users/sign_in"

    fill_in "user_login", with: user.login
    fill_in "user_password", with: password

    click_button "Sign in"
  end
end

RSpec.configure do |config|
  config.include FeatureTestHelper, type: :feature
end

# Determine if a class is directly present on a Capybara node
RSpec::Matchers.define :have_class do |expected_class|
  def valid_class_name?(class_name)
    class_name.match(/^-?[_a-zA-Z][_a-zA-Z0-9-]*$/) != nil
  end

  match do |actual_node|
    raise "not a valid class name: #{expected_class}" unless valid_class_name?(expected_class)
    actual_node['class'].split.include? expected_class
  end
end
