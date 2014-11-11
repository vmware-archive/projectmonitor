class Payload

  class InvalidContentException < ::StandardError
  end

  attr_accessor :parsed_url, :error_text, :error_type, :backtrace, :remote_addr

  def initialize
    self.processable = true
    self.build_processable = true
  end

  def each_status
    status_content.each do |content|
      next if !content_ready?(content)
      yield ProjectStatus.new(
        success: parse_success(content),
        url: parse_url(content),
        build_id: parse_build_id(content),
        published_at: parse_published_at(content)
      )
    end
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

  def convert_content!(raw_content)
    raw_content
  end

  def convert_json_content!(raw_content)
    Array.wrap(JSON.parse(raw_content))
  rescue => e
    handle_processing_exception e
  end

  def convert_xml_content!(raw_content, preserve_case = false)
    raw_content = raw_content.downcase unless preserve_case
    parsed_xml = Nokogiri::XML.parse(raw_content)
    raise Payload::InvalidContentException, "Error converting content for project #{@project_name}" unless parsed_xml.root
    parsed_xml
  rescue => e
    handle_processing_exception e
  end

  def convert_webhook_content!(raw_content)
    begin
      convert_content!(raw_content)
    rescue InvalidContentException => e
      log_error e
    end
  end

  def convert_build_content!(raw_content)
    convert_content!(raw_content)
  end

  def log_error(e)
    self.error_type = e.class.to_s
    self.error_text = e.message
    self.backtrace = "#{e.message}\n#{e.backtrace.join("\n")}"
  end

  def handle_processing_exception(e)
    self.processable = self.build_processable = false
    raise Payload::InvalidContentException, e.message
  end

  attr_accessor :processable, :build_processable
  attr_reader :status_content, :build_status_content
end
