class TimeZoneProxy
  attr_reader :target

  def initialize(target)
    raise "Target time zone may not be nil" if target.nil?
    @target = target
  end

  def now
    Clock.now.in_time_zone(@target)
  end

  def today
    Clock.now.in_time_zone(@target).to_date
  end

  def ==(rhs)
    super(rhs) || self.target == rhs || (rhs.respond_to?(:target) && self.target == rhs.target)
  end

  def method_missing(method, *args)
    target.send(method, *args)
  end
end
