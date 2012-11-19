# Load the rails application
require File.expand_path('../application', __FILE__)

::RED_NOTIFICATION_EMAILS = ["notify@example.com"]
::SYSTEM_ADMIN_EMAIL = "Pivotal Project Monitor <pivotal-projectmonitor@example.com>"


ProjectMonitor::Application.initialize!

Time::DATE_FORMATS[:db_time] = "%H:%M"
Time::DATE_FORMATS[:db_day] = "%A"
DateTime::DATE_FORMATS[:db_time] = "%H:%M"
DateTime::DATE_FORMATS[:db_day] = "%A"

ActionMailer::Base.smtp_settings = {
  :address  => "smtp.sendgrid.net",
  :port  => 587,
  :user_name  => ENV['SENDGRID_USERNAME'],
  :password  => ENV['SENDGRID_PASSWORD'],
  :authentication  => :plain,
  :domain => 'heroku.com'
}
ActionMailer::Base.delivery_method = :smtp
