class CodeshipPayload < Payload

  def initialize(project_id)
    super()
    @project_id = project_id
  end

  def building?
    !content_ready?(@build_status_content.first)
  end

  def content_ready?(content)
    content['status'] != 'testing'
  end

  def convert_content!(raw_content)
    convert_json_content!(raw_content).first.try(:[], 'builds') || []
  end

  alias_method :convert_build_content!, :convert_content!

  def convert_webhook_content!(params)
    content = params['build']
    @project_id = content['project_id']

    Array.wrap(content)
  end

  def parse_success(content)
    content['status'] == 'success'
  end

  def parse_url(content)
    "https://www.codeship.io/projects/#{@project_id}/builds/#{parse_build_id(content)}"
  end

  def parse_build_id(content)
    # Key depends on whether content is from polling or webhook
    content['id'] || content['build_id']
  end

  def parse_published_at(content)
    nil
  end

end
