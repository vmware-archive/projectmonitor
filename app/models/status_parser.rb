class StatusParser
  attr_accessor :success, :building, :url, :published_at
  def building?
    @building
  end

  def success?
    @success
  end
end

