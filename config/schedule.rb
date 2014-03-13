every :day, at: '3:00am' do
  rake "truncate:payload_log_entries", output: "log/payload_log_entries.log"
  rake "truncate:project_statuses", output: "log/project_statuses.log"
  rake "projectmonitor:remove_unused_tags"
end

every 3.minutes do
  rake "projectmonitor:fetch_statuses", output: "log/fetch_statuses.log"
end
