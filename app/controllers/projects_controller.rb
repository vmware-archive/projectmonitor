class ProjectsController < ApplicationController
  skip_filter :authenticate_user!, only: [:show, :status, :index]
  before_filter :load_project, only: [:edit, :update, :destroy]
  around_filter :scope_by_aggregate_project

  respond_to :json, only: [:index, :show]

  def index
    if params[:aggregate_project_id].present?
      projects = AggregateProject.find(params[:aggregate_project_id]).projects.decorate
    else
      standalone_projects = Project.standalone.displayable(params[:tags]).decorate
      aggregate_projects = AggregateProject.displayable(params[:tags]).decorate
      projects = standalone_projects + aggregate_projects
    end
    @projects = projects.sort_by(&:code)

    respond_with @projects
  end

  def new
    @project = Project.new
  end

  def create
    klass = params[:project][:type].present? ? params[:project][:type].constantize : Project
    @project = klass.new(project_params)
    @project.creator = current_user
    if @project.save
      redirect_to edit_configuration_path, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def show
    respond_with Project.find(params[:id])
  end

  def update
    if params[:password_changed] != 'true'
      params[:project].delete(:auth_password)
    else
      params[:project][:auth_password] = nil unless params[:project][:auth_password].present?
    end

    Project.transaction do
      old_class = @project.class
      if params[:project][:type] && @project.type != params[:project][:type]
        @project = @project.becomes(params[:project][:type].constantize)
        if project = Project.where(id: @project.id)
          project.update_all(type: params[:project][:type])
        end
      end

      if @project.update_attributes(project_params)
        redirect_to edit_configuration_path, notice: 'Project was successfully updated.'
      else
        if project = Project.where(id: @project.id)
          project.update_all(type: old_class.name)
        end
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
    head(422) and return if !params.has_key?(:project)

    project = params[:project][:type].constantize.new(project_params)

    if existing_project_missing_password?
      existing_project = Project.find(params[:project][:id])
      project.auth_password = existing_project.auth_password if existing_project
    end

    status_updater = StatusUpdater.new
    project_updater = ProjectUpdater.new(payload_processor: PayloadProcessor.new(project_status_updater: status_updater))
    log_entry = project_updater.update(project)

    render json: {
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

  def existing_project_missing_password?
    params[:project][:id].present? && params[:project][:auth_password].empty?
  end

  def project_params
    params.require(:project).permit(%i(aggregate_project_id auth_password auth_username
                                       build_branch code cruise_control_rss_feed_url enabled
                                       jenkins_base_url jenkins_build_name name online
                                       semaphore_api_url tag_list tddium_auth_token tddium_base_url tddium_project_name
                                       team_city_base_url team_city_build_name tracker_auth_token
                                       tracker_online tracker_project_id travis_github_account
                                       travis_repository type verify_ssl webhooks_enabled
                                       circleci_username circleci_project_name circleci_auth_token travis_pro_token
                                       concourse_base_url concourse_job_name ci_base_url ci_build_identifier ci_auth_token
                                       concourse_pipeline_name))
  end
end
