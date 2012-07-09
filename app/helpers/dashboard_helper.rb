module DashboardHelper

  def tracker_histogram(project)
    tracker_histogram = TrackerHistogram.new(project.last_ten_velocities.reverse)

    content_tag(:dl, class: "chart") do
      tracker_histogram.each_bar do |bar|
        concat tracker_histogram_bar(bar.height_percentage, bar.opacity)
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

  def tile_for(tile_obj)
    return tile_obj if tile_obj.nil? || tile_obj.is_a?(Location)
    ProjectDecorator.new(tile_obj)
  end

  private

  def tracker_histogram_bar(percentage, opacity)
    content_tag(:dd) do
      concat tag(:span, style: "opacity: #{opacity}; height: #{percentage}%")
    end
  end
end


