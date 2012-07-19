class DashboardsController < ApplicationController
  layout "dashboard"

  respond_to :html, :json, :only => :index
  respond_to :rss, :only => :builds

  def index
    projects = Project.displayable(params[:tags])
    aggregate_projects = AggregateProject.displayable(params[:tags])

    @tiles = DashboardGrid.arrange projects + aggregate_projects, params.slice(:tiles_count, :view)
    respond_with @tiles
  end

  def builds
    @projects = Project.standalone.with_statuses + AggregateProject.with_statuses
    respond_with @projects
  end

end

