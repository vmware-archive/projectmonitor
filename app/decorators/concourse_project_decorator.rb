class ConcourseProjectDecorator < ProjectDecorator

  def current_build_url
    "#{object.ci_base_url}/jobs/#{object.ci_build_identifier}"
  end

end
