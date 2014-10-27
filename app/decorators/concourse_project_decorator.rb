class ConcourseProjectDecorator < ProjectDecorator

  def current_build_url
    "#{object.concourse_base_url}/jobs/#{object.concourse_job_name}"
  end

end
