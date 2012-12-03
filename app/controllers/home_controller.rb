class HomeController < ApplicationController
  layout 'dashboard'

  respond_to :json, :only => [:index]

  def index
    aggregate_projects = AggregateProject.displayable(params[:tags])
    standalone_projects =  Project.standalone.displayable(params[:tags])
    projects = standalone_projects.concat(aggregate_projects).sort_by { |p| p.code.downcase }

    @tiles = projects
  end
end
