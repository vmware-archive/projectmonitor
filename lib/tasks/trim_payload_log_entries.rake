require 'trim_payload_log_entries'

desc "Reduce the number of payload_log_entries in each project to the #{TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP} most recent"
task :trim_payload_log_entries => :environment do
  TrimPayloadLogEntries.new.run
end
