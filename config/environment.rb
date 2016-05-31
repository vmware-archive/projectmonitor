# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

Time::DATE_FORMATS[:db_time] = "%H:%M"
Time::DATE_FORMATS[:db_day] = "%A"
DateTime::DATE_FORMATS[:db_time] = "%H:%M"
DateTime::DATE_FORMATS[:db_day] = "%A"
