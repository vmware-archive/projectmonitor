module ControllerTestHelper
  def log_in(user)
    controller.send("current_user=", user)
  end
end

RSpec.configure do |config|
  config.include ControllerTestHelper, :type => :controller
end
