class ProjectsController < ApplicationController
  before_filter :login_required
  before_filter :load_project, :only => [:show, :edit, :update, :destroy]

  def index
    @projects = Project.find(:all, :order => 'name')
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to projects_url
    else
      render :action => "new"
    end
  end

  def update
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to projects_url
    else
      render :action => "edit"
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url
  end

  protected

  private

  def load_project
    @project = Project.find(params[:id])
  end
end
