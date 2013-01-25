require 'net/http'
require 'net/https'

class UrlRetriever
  def initialize(url, username = nil, password = nil, verify_ssl = true)
    @url = url
    @username = username
    @password = password
    @verify_ssl = verify_ssl
  end

  def get
    get_request = Net::HTTP::Get.new "#{uri.path}?#{uri.query}"
    yield get_request if block_given?
    http.request(get_request)
  rescue Errno::ECONNREFUSED
    raise Net::HTTPError.new("Error: Could not connect to the remote server", nil)
  end

  def http
    Net::HTTP.new(uri.host, uri.port).tap do |http|
      if uri.scheme == 'https'
        http.use_ssl = true
        if @verify_ssl
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

  def retrieve_content
    response = if @username && @password
                 get { |get_request| get_request.basic_auth(@username, @password) }
               else
                 get
               end

    process_response response
  end

  def uri
    if /\A\S+:\/\// === @url
      URI.parse @url
    else
      URI.parse "http://#{@url}"
    end
  end

  private

  def process_response(response)
    case response.code.to_i
      when 200..299
        response.body
      #when 400..599
      else
        raise Net::HTTPError.new("Got #{response.code} response status from #{@url}, body = '#{response.body}'", nil)
    end
  end
end
