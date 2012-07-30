class ConfigurationController < ApplicationController
  before_filter :login_required

  def show
    headers['Content-type'] = 'text/plain'
    headers['Content-Disposition'] = %{attachment; filename="configuration.yml"}
    headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
    render :text => ConfigExport.export
  end

  def create
    ConfigExport.import params[:content].read
    head :ok
  end

end
