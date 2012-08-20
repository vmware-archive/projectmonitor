class PayloadLogEntriesController < ApplicationController
  def index
    @project = Project.find_by_id(params[:project_id])
    @payload_log_entries = @project.payload_log_entries
  end
end
