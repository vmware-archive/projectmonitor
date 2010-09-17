module ControllerTestHelper
  def log_in(user)
    controller.send("current_user=", user)
  end
end