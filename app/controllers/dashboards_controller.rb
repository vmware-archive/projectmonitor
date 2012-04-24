class DashboardsController < ApplicationController
  layout "dashboard"

  def index
    # @projects = @projects.sort_by{|p| p.name.downcase }
    @projects = DashboardGrid.generate params
  end

  def builds
    @projects = Project.standalone.with_statuses + AggregateProject.with_statuses
  end
end

