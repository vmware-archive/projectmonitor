class ConfigurationController < ApplicationController
  before_action :authenticate_user!

  respond_to :text, only: :show

  def show
    headers['Content-Type'] = 'text/plain'
    headers['Content-Disposition'] = %{attachment; filename="configuration.yml"}
    headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
    render plain: ConfigExport.export
  end

  def create
    ConfigExport.import params[:content].read
    head :ok
  end

  def edit
    @projects = Project.order(:name).includes(:tags, :latest_payload_log_entry)
    @aggregate_projects = AggregateProject.order(:name)
    @tags = ActsAsTaggableOn::Tag.order(:name).map(&:name)
  end

end
