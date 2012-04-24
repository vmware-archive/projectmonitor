module DashboardHelper
  def container_class
    return "container_12" if @projects.blank? || @projects.size < 63
    "container_7"
  end

  def grid_class
    return "grid_4" if @projects.blank?

    if @projects.size <= 15
      "grid_4"
    elsif @projects.size <= 24
      "grid_3"
    elsif @projects.size <= 48
      "grid_2"
    else
      "grid_1"
    end
  end

  def tile_for(tile_obj)
    return tile_obj if tile_obj.nil? || tile_obj.is_a?(Location)
    ProjectDecorator.new(tile_obj)
  end
end
