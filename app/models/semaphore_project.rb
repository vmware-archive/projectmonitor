class SemaphoreProject < Project

  validates_presence_of :semaphore_api_url, unless: ->(project) { project.webhooks_enabled }

  alias_attribute :feed_url, :semaphore_api_url
  alias_attribute :build_status_url, :feed_url

  def self.project_specific_attributes
    ['semaphore_api_url']
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

  def requires_branch_name?
    true
  end
end
