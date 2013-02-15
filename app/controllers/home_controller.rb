class HomeController < ApplicationController
  layout 'home'

  respond_to :html, :only => [:styleguide]
  respond_to :rss, :only => :builds
  respond_to :json, :only => [:github_status, :heroku_status, :rubygems_status, :index]

  def index
    if aggregate_project_id = params[:aggregate_project_id]
      projects = AggregateProject.find(aggregate_project_id).projects
    else
      aggregate_projects = AggregateProject.displayable(params[:tags])
      standalone_projects = Project.standalone.displayable(params[:tags])
      projects = standalone_projects.concat(aggregate_projects).sort_by { |p| p.code.downcase }
    end

    @projects = projects
  end

  def builds
    @projects = Project.standalone.with_statuses + AggregateProject.with_statuses
    respond_with @projects
  end

  def github_status
    github = ExternalDependency.get_or_fetch_recent_status('GITHUB')
    respond_with github.status
  end

  def heroku_status
    heroku = ExternalDependency.get_or_fetch_recent_status('HEROKU')
    respond_with heroku.status
  end

  def rubygems_status
    rubygems = ExternalDependency.get_or_fetch_recent_status('RUBYGEMS')
    respond_with rubygems.status
  end

  def styleguide
  end
end
