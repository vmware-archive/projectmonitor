class DashboardsController < ApplicationController
  layout "dashboard"

  respond_to :html, :json, :only => :index
  respond_to :rss, :only => :builds

  def index
    @tiles = DashboardGrid.generate params
    respond_with @tiles
  end

  def builds
    @projects = Project.standalone.with_statuses + AggregateProject.with_statuses
    respond_with @projects
  end
end

