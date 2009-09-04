require 'httpauth'

class UrlRetriever
  def retrieve_content_at(url, username = nil, password = nil)
    response = do_get(url)
    unless response['www-authenticate'].nil?
      response = do_get(url) { |get| get.basic_auth(username, password)}
      unless response['www-authenticate'].nil?
        response = do_get(url) { |get| digest_auth(get, response, username, password) }
      end
    end
    raise Net::HTTPError.new("Error: got non-200 return code #{response.code} from #{url}, body = '#{response.body}'", nil) unless response.code.to_i == 200
    response.body
  end

  private

  def do_get(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 30
    http.open_timeout = 30

    get = Net::HTTP::Get.new(uri.path)

    yield(get) if block_given?

    res = http.start { |web| web.request(get)}
    res
  end

  def digest_auth(get, url, response, username, password)
    challenge = HTTPAuth::Digest::Challenge.from_header(response['www-authenticate'])
    credentials = HTTPAuth::Digest::Credentials.from_challenge(challenge, {:username => username, :password => password, :uri => uri.path, :method => 'GET'})
    get['Authorization'] = credentials.to_header
  end

end