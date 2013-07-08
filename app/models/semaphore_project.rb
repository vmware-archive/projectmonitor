class SemaphoreProject < Project

  validates_presence_of :semaphore_api_url, unless: ->(project) { project.webhooks_enabled }

  def current_build_url
    parsed_url
  end

  def feed_url
    semaphore_api_url
  end

  def fetch_payload
    SemaphorePayload.new.tap do |payload|
      payload.branch = build_branch
    end
  end

  def webhook_payload
    SemaphorePayload.new.tap do |payload|
      payload.branch = build_branch
    end
  end

  def build_status_url
    feed_url
  end
end
