module DashboardHelper
  def tile_for(tile_obj)
    return tile_obj if tile_obj.nil? || tile_obj.is_a?(Location)
    ProjectDecorator.new(tile_obj)
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
end
