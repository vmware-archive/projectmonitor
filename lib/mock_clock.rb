=begin
THREADING NOTE: The mock Clock is not thread-safe, ||= is not atomic.  Thus, thread A could modify @@now between thread
B's comparison of @@now to nil and assignment of @@now to Time.now.  The #tick method has a similar issue.

This should generally not be a problem, as tests shouldn't have a reason to modify the current time concurrently in
multiple threads.
=end

require 'clock/time_zone_proxy'

class Clock
  def self.now
    @@now ||= Time.now
  end

  def self.now=(new)
    @@now = new.to_time
  end

  def self.tick(duration)
    self.now += duration
  end

  def self.zone
    return nil if Time.zone.nil?
    TimeZoneProxy.new(Time.zone)
  end
end
