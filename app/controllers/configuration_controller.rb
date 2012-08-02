class ConfigurationController < ApplicationController
  before_filter :login_required

  respond_to :text, only: :show

  def show
    headers['Content-type'] = 'text/plain'
    headers['Content-Disposition'] = %{attachment; filename="configuration.yml"}
    headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
    respond_with ConfigExport.export
  end

  def create
    ConfigExport.import params[:content].read
    head :ok
  end

  def edit
    @projects = Project.order(:name).all
    @aggregate_projects = AggregateProject.order(:name)
  end

end
