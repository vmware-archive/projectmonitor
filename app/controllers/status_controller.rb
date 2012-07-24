class StatusController < ApplicationController
  def create
    project = Project.find(params.delete(:project_id))
    payload = Payload.for_project(project, :json).content(params)
    ProjectPayloadProcessor.new(project, payload).process
    head :ok
  end
end
