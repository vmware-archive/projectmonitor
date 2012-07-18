class Location
  def initialize(location = nil)
    @location = location
  end

  def to_s
    @location || "Other"
  end

  def to_partial_path
    "dashboards/location"
  end
end
