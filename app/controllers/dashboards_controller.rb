class DashboardsController < ApplicationController

  layout "dashboard"

  def index
    if tags = params[:tags].presence
      @projects = Project.standalone_with_tags(tags) + AggregateProject.all_with_tags(tags)
    else
      @projects = Project.standalone + AggregateProject.all
    end

    @projects = GridCollection.new @projects
  end
end
