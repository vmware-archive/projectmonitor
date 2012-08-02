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
    klass = params[:project][:type].present? ? params[:project][:type].constantize : Project
    @project = klass.new(params[:project])
    if @project.save
      redirect_to projects_url, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def status
    @project = ProjectDecorator.new(Project.find(params[:id]))
    render :partial => @project, :locals => {:tiles_count => params[:tiles_count].to_i}
  end

  def update
    if @project.update_attributes(params[:project])
      redirect_to projects_url, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  def validate_build_info
    project = params[:project][:type].constantize.new(params[:project])
    ProjectUpdater.update(project)
    head project.online ? :ok : 403
  end

  def validate_tracker_project
    status = TrackerProjectValidator.validate(params)
    head status
  end

  def update_projects
    if Delayed::Job.count.zero?
      StatusFetcher.fetch_all
      render nothing: true
    else
      render nothing: true, status: 409
    end
  end

  private

  def load_project
    @project = Project.find(params[:id])
  end
end
