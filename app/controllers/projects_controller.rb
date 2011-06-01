class ProjectsController < ApplicationController
  before_filter :login_required
  before_filter :load_project, :only => [:edit, :update, :destroy]
  before_filter :load_project_type, :only => [:create]

  def index
    @projects = Project.find(:all, :order => 'name')
    @aggregate_projects = AggregateProject.order(:name)
  end

  def new
    @project = Project.new
  end

  def create
    @project = @project_type.new(params[:project])
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to projects_url
    else
      render :action => "new"
    end
  end

  def update
    success = nil
    Project.transaction do
      if params[:project][:type].present?
        @project.update_attribute(:type, params[:project][:type])
        @project = Project.find(@project.id)
      end
      success = @project.update_attributes(params[:project])
      raise ActiveRecord::Rollback unless success
    end

    if success
      flash[:notice] = 'Project was successfully updated.'
      redirect_to projects_url
    else
      render :action => "edit"
    end
  end

  def destroy
    @project.destroy
    flash[:notice] = 'Project was successfully destroyed.'
    redirect_to projects_url
  end

  protected

  private

  def load_project
    @project = Project.find(params[:id])
  end

  def load_project_type
    @project_type = params[:project][:type].nil? ? Project : params[:project][:type].constantize 
  end
end
