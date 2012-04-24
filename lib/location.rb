class Location
  def initialize(location = nil)
    @location = location
  end

  def to_s
    @location || "Other"
  end
end
