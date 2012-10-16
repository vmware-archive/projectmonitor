every :day, :at => '3:00am' do
  rake "truncate:payload_log_entries"
end
