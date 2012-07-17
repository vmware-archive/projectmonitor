class StatusController < ApplicationController
  def create
    ProjectPayloadProcessor.new(Project.find(params[:project_id]), "[#{params[:payload]}]").perform
    head :ok
  end
end
