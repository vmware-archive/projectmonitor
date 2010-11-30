# Load the rails application
require File.expand_path('../application', __FILE__)

::RED_NOTIFICATION_EMAILS = ["notfiy@example.com"]

DELAYED_JOB_FETCH_INTERVAL_MINS = 3

CiMonitor::Application.initialize!