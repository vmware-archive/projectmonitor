class Payload
  def initialize(project)
    self.project = project
    self.processable = true
    self.build_processable = true
  end

  def self.for_project(project, format=nil)
    project.payload.for_format(format || project.payload_fetch_format).new(project)
  end

  def each_status
    status_content.map do |s|
      payload = self.class.new(project)
      payload.content = s
      yield payload
    end
  end

  def status_content=(content)
    @status_content = content
    convert_content!

    self
  end

  def build_status_content=(content)
    @build_status_content = content
    convert_build_content!

    self
  end

  def content(content)
    self.status_content = content
    self.build_status_content = content

    self
  end

  def status_is_processable?
    has_status_content? && !!processable
  end

  def build_status_is_processable?
    has_build_status_content? && !!build_processable
  end

  def success
    raise NotImplementedError
  end

  def url
    raise NotImplementedError
  end

  def build_id
    raise NotImplementedError
  end

  def published_at
    raise NotImplementedError
  end

  def building?
    raise NotImplementedError
  end

  def convert_content!
  end

  def convert_build_content!
  end

  attr_writer :content

  private

  def has_status_content?
    status_content.present?
  end

  def has_build_status_content?
    build_status_content.present?
  end

  attr_accessor :project, :processable, :build_processable
  attr_reader :status_content, :build_status_content
end
