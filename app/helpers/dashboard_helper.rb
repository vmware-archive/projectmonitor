module DashboardHelper
  def tile_for(tile_obj)
    return tile_obj if tile_obj.nil? || tile_obj.is_a?(Location)
    ProjectDecorator.new(tile_obj)
  end
end
