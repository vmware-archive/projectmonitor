require 'clockwork'
require 'clockwork/manager_with_database_tasks'
require_relative './config/boot'
require_relative './config/environment'

module Clockwork
  handler do |job|
    `rake #{job}`
  end

  every(10.minutes, 'projectmonitor:poller')
  every(1.day, 'truncate:payload_log_entries[2]')
  every(1.day, 'truncate:project_statuses[1000]')
end
