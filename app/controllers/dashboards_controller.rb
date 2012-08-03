class DashboardsController < ApplicationController
  layout "dashboard"

  respond_to :html, :json, :only => :index
  respond_to :rss, :only => :builds

  def index
    @tiles_count = (params[:tiles_count].presence || 15).to_i

    aggregate_projects = []
    projects = if aggregate_project_id = params[:aggregate_project_id]
                 AggregateProject.find(aggregate_project_id).projects
               else
                 aggregate_projects = AggregateProject.displayable(params[:tags])
                 Project.standalone
               end
    projects =  projects.displayable(params[:tags]).all

    @tiles = ProjectDecorator.decorate(projects | aggregate_projects)
      .sort_by{|p| p.code.downcase }
      .take(@tiles_count)

    respond_with @tiles
  end

  def builds
    @projects = Project.standalone.with_statuses + AggregateProject.with_statuses
    respond_with @projects
  end

end

