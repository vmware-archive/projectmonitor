class ConcourseProjectDecorator < ProjectDecorator

  def current_build_url
    "#{object.ci_base_url}/teams/main/pipelines/#{object.concourse_pipeline_name}"
  end
end
