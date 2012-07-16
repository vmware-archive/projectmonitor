module TeamCityProjectWithChildren

  def children
    TeamCityChildBuilder.parse(self, build_type_fetcher.call)
  rescue Net::HTTPError
    []
  end

  private
  def build_type_url
    uri = URI(feed_url)
    "#{uri.scheme}://#{uri.host}:#{uri.port}/httpAuth/app/rest/buildTypes/id:#{build_id}"
  end

  def build_type_fetcher
    @build_type_fetcher ||= proc {
      UrlRetriever.retrieve_content_at(build_type_url, auth_username, auth_password)
    }
  end

end
