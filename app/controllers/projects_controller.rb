class ProjectsController < ApplicationController
  before_filter :login_required, :except => :status
  before_filter :load_project, :only => [:edit, :update, :destroy]

  def index
    @projects = Project.find(:all, :order => 'name')
    @aggregate_projects = AggregateProject.order(:name)
  end

  def new
    @project = Project.new
  end

  def create
    handle_feed_url
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to projects_url
    else
      render :new
    end
  end

  def status
    @project = ProjectDecorator.new(Project.find(params[:id]))
    render :partial => "dashboards/project", :locals => { :project => @project, :projects_count => params[:projects_count].to_i }
  end

  def update
    handle_feed_url
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to projects_url
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    flash[:notice] = 'Project was successfully destroyed.'
    redirect_to projects_url
  end

  def validate_tracker_project
    status = TrackerProjectValidator.validate(params)
    head status
  end

  private

  def handle_feed_url
    if params[:feed_url]
      parser = URLParser.new(params[:feed_url], params[:project][:type])
      params[:project].merge!({feed_url: parser.url, serialized_feed_url_parts: params[:feed_url]})
    end
  end

  def load_project
    @project = Project.find(params[:id])
  end
end
