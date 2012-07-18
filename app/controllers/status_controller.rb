class StatusController < ApplicationController
  def create
    project = Project.find(params.delete(:project_id))
    ProjectPayloadProcessor.new(project, params).perform
    head :ok
  end
end
