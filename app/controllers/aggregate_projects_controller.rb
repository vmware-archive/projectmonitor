class AggregateProjectsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :status, :index]
  before_filter :load_aggregate_project, :only => [:show, :edit, :update, :destroy]

  respond_to :json, only: [:index, :show]

  def index
    respond_with AggregateProject.all
  end

  def new
    @aggregate_project = AggregateProject.new
  end

  def create
    @aggregate_project = AggregateProject.new(aggregate_project_params)
    if @aggregate_project.save
      redirect_to edit_configuration_path, notice: 'Aggregate project was successfully created.'
    else
      render :new
    end
  end

  def show
    respond_with AggregateProject.find(params[:id])
  end

  def update
    if @aggregate_project.update_attributes(aggregate_project_params)
      redirect_to edit_configuration_path, notice: 'Aggregate project was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @aggregate_project.destroy
    redirect_to edit_configuration_path, notice: 'Aggregate project was successfully destroyed.'
  end

  private

  def load_aggregate_project
    @aggregate_project = AggregateProject.find(params[:id])
  end

  def aggregate_project_params
    params.require(:aggregate_project).permit(:name)
  end
end
