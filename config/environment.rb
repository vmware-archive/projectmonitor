# Load the rails application
require File.expand_path('../application', __FILE__)

ProjectMonitor::Application.initialize!

Time::DATE_FORMATS[:db_time] = "%H:%M"
Time::DATE_FORMATS[:db_day] = "%A"
DateTime::DATE_FORMATS[:db_time] = "%H:%M"
DateTime::DATE_FORMATS[:db_day] = "%A"
