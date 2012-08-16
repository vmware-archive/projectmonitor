class SemaphoreProject < Project

  attr_accessible :semaphore_api_url
  validates_presence_of :semaphore_api_url

  def feed_url
    semaphore_api_url
  end

  def build_status_url
    feed_url
  end

  def fetch_payload
    SemaphorePayload.new
  end

  def webhook_payload
    SemaphorePayload.new
  end

end
