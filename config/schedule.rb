every :day, :at => '3:00am' do
  rake "truncate:payload_log_entries", :output => "payload_log_entries.log"
  rake "truncate:project_statuses", :output => "project_statuses.log"
end

every 3.minutes do
  rake "cimonitor:fetch_statuses", :output => "fetch_statuses.log"
end

every :weekday, :at => '8:30am' do
  rake "cimonitor:red_over_one_day_notification", :output => "red_notify.log"
end
