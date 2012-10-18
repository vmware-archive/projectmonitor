class Payload

  class InvalidContentException < ::Exception
  end

  attr_writer :dependent_content
  attr_accessor :parsed_url, :error_text, :error_type, :backtrace, :remote_addr

  def initialize
    self.processable = true
    self.build_processable = true
  end

  def each_status
    status_content.each do |content|
      next if parse_success(content) == nil
      yield ProjectStatus.new(
        success: parse_success(content),
        url: parse_url(content),
        build_id: parse_build_id(content),
        published_at: parse_published_at(content)
      )
    end
  end

  def each_child(project)
  end

  def webhook_status_content=(content)
    @status_content = convert_webhook_content!(content).first(Project::RECENT_STATUS_COUNT)
    @build_status_content = @status_content
  end

  def status_content=(content)
    begin
      @status_content = convert_content!(content).first(Project::RECENT_STATUS_COUNT)
    rescue InvalidContentException => e
      log_error e
      @status_content = []
    end
  end

  def build_status_content=(content)
    begin
      @build_status_content = convert_build_content!(content)
    rescue InvalidContentException => e
      log_error e
    end
  end

  def status_is_processable?
    has_status_content? && !!processable
  end

  def build_status_is_processable?
    has_build_status_content? && !!build_processable
  end

  def building?
    raise NotImplementedError
  end

  def has_status_content?
    status_content.present?
  end

  def has_build_status_content?
    build_status_content.present?
  end

  def has_dependent_content?
    dependent_content.present?
  end

  def convert_content!(content)
    content
  end

  def convert_webhook_content!(content)
    begin
      convert_content!(content)
    rescue InvalidContentException => e
      log_error e
    end
  end

  def convert_build_content!(content)
    convert_content!(content)
  end

  def log_error(e)
    self.error_type = e.class.to_s
    self.error_text = e.message
    self.backtrace = "#{e.message}\n#{e.backtrace.join("\n")}"
  end

  attr_accessor :processable, :build_processable
  attr_reader :status_content, :build_status_content, :dependent_content

end


