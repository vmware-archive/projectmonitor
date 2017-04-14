require 'clockwork'
require_relative './config/boot'
require_relative './config/environment'

module Clockwork
  handler do |job|
    `rake #{job}`
  end

  every(1.day, 'truncate:project_statuses[1000]')
  every(1.minute, 'trim_payload_log_entries')
end
