# Load the rails application
require File.expand_path('../application', __FILE__)

::RED_NOTIFICATION_EMAILS = ["notify@example.com"]
::SYSTEM_ADMIN_EMAIL = "Pivotal Project Monitor <pivotal-projectmonitor@example.com>"


CiMonitor::Application.initialize!

Time::DATE_FORMATS[:db_time] = "%H:%M"
Time::DATE_FORMATS[:db_day] = "%A"
DateTime::DATE_FORMATS[:db_time] = "%H:%M"
DateTime::DATE_FORMATS[:db_day] = "%A"
