module DashboardHelper
  def grid_class
    return "grid_4" if @projects.nil?

    if @projects.size <= 15
      "grid_4"
    elsif @projects.size <= 24
      "grid_3"
    else
      "grid_2"
    end
  end
end
