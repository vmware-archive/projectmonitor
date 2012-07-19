class AggregateProjectsController < ApplicationController
  before_filter :login_required, :except => [:show, :status]
  before_filter :load_aggregate_project, :only => [:show, :edit, :update, :destroy]

  layout "dashboard", only: [ :show ]

  def show
    projects = @aggregate_project.projects.enabled
    @tiles = DashboardGrid.arrange projects
    render 'dashboards/index'
  end

  def new
    @aggregate_project = AggregateProject.new
  end

  def create
    @aggregate_project = AggregateProject.new(params[:aggregate_project])
    if @aggregate_project.save
      redirect_to projects_url, notice: 'Aggregate project was successfully created.'
    else
      render :new
    end
  end

  def status
    @aggregate_project = ProjectDecorator.new(AggregateProject.find(params[:id]))

    render @aggregate_project, :tiles_count => params[:tiles_count].to_i
  end

  def update
    if @aggregate_project.update_attributes(params[:aggregate_project])
      redirect_to projects_url, notice: 'Aggregate project was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @aggregate_project.destroy
    redirect_to projects_url, notice: 'Aggregate project was successfully destroyed.'
  end

  private

  def load_aggregate_project
    @aggregate_project = AggregateProject.find(params[:id])
  end

end
