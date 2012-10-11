every :day, :at => '3:00am' do
  rake "truncate_ci_server_logs"
end
