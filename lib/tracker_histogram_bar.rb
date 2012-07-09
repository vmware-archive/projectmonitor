class TrackerHistogramBar
  def initialize(tracker_histogram, points_value, index)
    self.tracker_histogram = tracker_histogram
    self.points_value = points_value
    self.index = index
  end

  delegate :number_of_points_values, :maximum_points_value, :opacity_step, :to => :tracker_histogram

  def height_percentage
    (points_value.to_f / maximum_points_value * 100).to_i + TrackerHistogram::ZERO_OFFSET
  end

  def opacity
    (1 - ((number_of_points_values - (index + 1)) * opacity_step)).round(2)
  end

  private

  attr_accessor :tracker_histogram, :points_value, :index
end
