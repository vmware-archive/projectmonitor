module DashboardHelper
  def project_bar_chart(project)
    points_per_iteration = project.last_ten_velocities
    maximum_point_value = points_per_iteration.max

    content_tag(:dl, class: "chart") do
      points_per_iteration.each do |iteration_points|
        concat bar_chart_bar(iteration_points.to_f / maximum_point_value * 100)
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

  def bar_chart_bar(percentage)
    content_tag(:dd) do
      concat tag(:span, style: "height: #{percentage.to_i}%")
    end
  end
end
