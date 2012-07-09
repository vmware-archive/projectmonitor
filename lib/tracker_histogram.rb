class TrackerHistogram
  ZERO_OFFSET = 5

  def initialize(points_per_iteration)
    self.points_per_iteration = points_per_iteration
  end

  def each_bar(&block)
    points_per_iteration.each_with_index do |point, index|
      yield TrackerHistogramBar.new(self, point, index)
    end
  end

  def maximum_points_value
    points_per_iteration.max
  end

  def number_of_points_values
    points_per_iteration.count
  end

  def opacity_step
    minimum_opacity = 0.3
    (1 - minimum_opacity) / number_of_points_values
  end

  private

  attr_accessor :points_per_iteration
end
