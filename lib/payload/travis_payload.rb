class TravisPayload < Payload
  def self.for_format(format)
    TravisPayload
  end

  def success
    return if @content["state"] == "started"
    @content["result"].to_i == 0
  end

  def url
    project.feed_url.gsub(".json", "/#{@content["id"]}")
  end

  def build_id
    @content["id"]
  end

  def published_at
    published_at = @content["finished_at"]
    Time.parse(published_at).localtime if published_at.present?
  end

  def building?
    @status_content.first["state"] == "started"
  end

  def build_status_is_processable?
    status_is_processable?
  end

  private

  def convert_content!
    begin
      converted_content = status_content
      converted_content = converted_content.fetch("payload", converted_content) if converted_content.respond_to?(:fetch)
      converted_content = Array.wrap(JSON.parse(converted_content)).first if converted_content
      @status_content = [converted_content]
    rescue JSON::ParserError
      self.processable = false
    end
  end
end
