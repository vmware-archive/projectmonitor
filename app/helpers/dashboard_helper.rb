module DashboardHelper

  def tracker_histogram(project)
    tracker_histogram = TrackerHistogram.new(project.last_ten_velocities.reverse)

    content_tag(:dl, class: "chart") do
      tracker_histogram.each_bar do |bar|
        concat tracker_histogram_bar(bar.height_percentage, bar.opacity, bar.points_value)
      end
    end.html_safe
  end

  def status_count_for(number)
    case number
    when 15, 24
      8
    when 48
      6
    when 63
      5
    else
      6
    end
  end

  private

  def tracker_histogram_bar(percentage, opacity, points_value)
    content_tag(:dd, :title => "#{pluralize(points_value, "point")} completed") do
      concat tag(:span, style: "opacity: #{opacity}; height: #{percentage}%")
    end
  end
end


