class HttpRequester
  def initialize
    @connection_timeout = 60
    @inactivity_timeout = 30
    @max_follow_redirects = 10
  end

  def initiate_request(url, options = {})
    url = "http://#{url}" unless /\A\S+:\/\// === url
    begin
      connection = EM::HttpRequest.new url, connect_timeout: @connection_timeout, inactivity_timeout: @inactivity_timeout
      get_options = {redirects: @max_follow_redirects}.merge(options)
      connection.get get_options
    rescue Addressable::URI::InvalidURIError => e
      puts "ERROR parsing URL: \"#{url}\""
    end
  end
end