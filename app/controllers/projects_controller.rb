class ProjectsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :status, :index]
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
    if @project.auth_password.present? && (params[:project][:auth_password].nil? || params[:project][:auth_password].empty?)
      params[:project].delete(:auth_password)
    end
    Project.transaction do
      if params[:project][:type] && @project.type != params[:project][:type]
        @project = @project.becomes(params[:project][:type].constantize)
        if project = Project.where(id: @project.id)
          project.update_all(type: params[:project][:type])
        end
      end

      if @project.update_attributes(params[:project])
        redirect_to edit_configuration_path, notice: 'Project was successfully updated.'
      else
        render :edit
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy
    @project.destroy
    redirect_to edit_configuration_path, notice: 'Project was successfully destroyed.'
  end

  def validate_build_info
    project = params[:project][:type].constantize.new(params[:project])
    log_entry = ProjectUpdater.update(project)

    render :json => {
      status: log_entry.status == 'successful',
      error_type: log_entry.error_type,
      error_text: log_entry.error_text.to_s[0,10000]
    }
  end

  def validate_tracker_project
    project = Project.find(params[:id])
    status = :accepted
    if project.tracker_validation_status.present? &&
      project.tracker_validation_status[:auth_token] == params[:auth_token] &&
      project.tracker_validation_status[:project_id] == params[:project_id]
      status = project.tracker_validation_status[:status]
    else
      TrackerProjectValidator.delay(priority: 0).validate(params)
      project.tracker_validation_status = {auth_token: params[:auth_token], project_id: params[:project_id], status: :accepted}
      project.save!
    end
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
