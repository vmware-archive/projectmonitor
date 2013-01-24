require 'net/http'
require 'net/https'

module UrlRetriever
  def self.retrieve_content_at(url, username, password, verify_ssl = true)
    response = get(url, verify_ssl) { |get_request| get_request.basic_auth(username, password) }
    process_response response, url
  end

  def self.retrieve_public_content_at(url)
    response = get url, true
    process_response response, url
  end

  def self.process_response(response, url)
    case response.code.to_i
      when 200..299
        response.body
      #when 400..599
      else
        raise Net::HTTPError.new("Got #{response.code} response status from #{url}, body = '#{response.body}'", nil)
    end
  end

  def self.parse_uri(url)
    url = "http://#{url}" unless url.match %r{\A\S+://}
    URI.parse url
  end

  def self.http(uri, verify_ssl)
    Net::HTTP.new(uri.host, uri.port).tap do |http|
      if uri.scheme == 'https'
        http.use_ssl = true
        if verify_ssl
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        else
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.ca_file = Rails.root.join(ConfigHelper.get(:certificate_bundle))
      end
      http.read_timeout = 30
      http.open_timeout = 30
    end
  end

  def self.get(url, verify_ssl)
    uri = parse_uri url
    get_request = Net::HTTP::Get.new "#{uri.path}?#{uri.query}"
    yield get_request if block_given?
    http(uri, verify_ssl).request(get_request)
  rescue Errno::ECONNREFUSED
    raise Net::HTTPError.new("Error: Could not connect to the remote server", nil)
  end

end
