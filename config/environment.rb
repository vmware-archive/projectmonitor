# Load the rails application
require File.expand_path('../application', __FILE__)

::RED_NOTIFICATION_EMAILS = ["notify@example.com"]
::SYSTEM_ADMIN_EMAIL = "Pivotal CiMonitor <pivotal-cimonitor@example.com>"

DELAYED_JOB_FETCH_INTERVAL_MINS = 3

CiMonitor::Application.initialize!