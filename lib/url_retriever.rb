module UrlRetriever

  def self.retrieve_content_at(url, username = nil, password = nil)
    http_client = HTTPClient.new

    if username.present?
      http_client.set_auth(url, username, password)
    end

    message = http_client.get(url)
    if message.code == 200
      message.body
    else
      raise Net::HTTPError.new("Error: got non-200 return code #{message.code} from #{url}, body = '#{message.body}'", nil)
    end
  end

end
