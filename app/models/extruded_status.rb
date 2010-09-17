class ExtrudedStatus
  attr_accessor :success, :url, :published_at

  def success?
    @success
  end
end