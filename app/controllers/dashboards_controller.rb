class DashboardsController < ApplicationController
  layout "dashboard"

  def index
    @projects = DashboardGrid.generate params

    respond_to do |format|
      format.html
      format.json { render :json => @projects }
    end
  end

  def builds
    @projects = Project.standalone.with_statuses + AggregateProject.with_statuses
  end
end

