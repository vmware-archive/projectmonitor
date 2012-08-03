class ProjectsController < ApplicationController
  before_filter :login_required, :except => [:show, :status, :index]
  before_filter :load_project, :only => [:edit, :update, :destroy]
  around_filter :scope_by_aggregate_project

  respond_to :json, only: [:index, :show]

  def index
    respond_with ProjectFeedDecorator.decorate Project.all
  end

  def new
    @project = Project.new
  end

  def create
    klass = params[:project][:type].present? ? params[:project][:type].constantize : Project
    @project = klass.create(params[:project])
    if @project.save
      redirect_to edit_configuration_path, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def status
    @tiles_count = (params[:tiles_count].presence || 15).to_i
    @project = ProjectDecorator.new(Project.find(params[:id]))
    render :partial => @project, :locals => {:tiles_count => @tiles_count}
  end

  def show
    respond_with Project.find(params[:id])
  end

  def update
    if @project.update_attributes(params[:project])
      redirect_to edit_configuration_path, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to edit_configuration_path, notice: 'Project was successfully destroyed.'
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

  def scope_by_aggregate_project
    if aggregate_project_id = params[:aggregate_project_id]
      Project.with_aggregate_project aggregate_project_id do
        yield
      end
    else
      yield
    end
  end

end
