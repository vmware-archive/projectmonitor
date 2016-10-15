require 'net/http'
require 'net/https'

class SynchronousHttpRequester
  def initialize(net_http_builder)
    @net_http_builder = net_http_builder
  end

  def retrieve_content(url)
    process_response(url, get(url))
  end

  private

  def formatted_uri(url)
    if /\A\S+:\/\// === url
      URI.parse url
    else
      URI.parse "http://#{url}"
    end
  end

  def get(url)
    uri = formatted_uri(url)
    get_request = Net::HTTP::Get.new "#{uri.path}?#{uri.query}"
    session = @net_http_builder.build(uri)
    session.request(get_request)
  rescue Errno::ECONNREFUSED
    raise Net::HTTPError.new("Error: Could not connect to the remote server", nil)
  end

  def process_response(url, response)
    case response.code.to_i
      when 200..299
        response.body
      when 300..399
        retrieve_content(response.header['location'])
      else
        raise Net::HTTPError.new("Got #{response.code} response status from #{url}, body = '#{response.body}'", nil)
    end
  end
end
