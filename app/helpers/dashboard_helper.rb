module DashboardHelper

  def build_history(project, tiles_count)
    build_history = BuildHistory.new(project.recent_statuses(status_count_for(tiles_count)))

    content_tag(:ol) do
      build_history.each_build do |build|
        concat historical_build_indicator(build.result, build.url, build.box_opacity, build.indicator_opacity)
      end
    end.html_safe
  end

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

  def historical_build_indicator(result, url, box_opacity, indicator_opacity)
    content_tag(:li, :class => result, :style => "opacity: #{box_opacity}") do
      content_tag(:span, :style => "opacity: #{indicator_opacity}") do
        concat link_to result, url || '#'
      end
    end
  end

  def tracker_histogram_bar(percentage, opacity, points_value)
    content_tag(:dd, :title => "#{pluralize(points_value, "point")} completed") do
      concat tag(:span, style: "opacity: #{opacity}; height: #{percentage}%")
    end
  end

end


