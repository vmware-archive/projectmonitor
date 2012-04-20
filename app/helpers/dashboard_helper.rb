module DashboardHelper
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

  def container_class
    return "container_12" if @projects.blank? || @projects.size < 63
    "container_7"
  end
end
