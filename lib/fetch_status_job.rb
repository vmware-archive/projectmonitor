class FetchStatusJob
  def perform
    StatusFetcher.new.fetch_all
  end
end