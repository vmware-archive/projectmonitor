require 'net/http'
require 'net/https'

module UrlRetriever

  class << self

    def retrieve_content_at(url, username = nil, password = nil, verify_ssl = true)
      if username.present? && password.present?
        response = do_get(url, verify_ssl) { |get| get.basic_auth(username, password) }
        if response['www-authenticate'].present?
          response = do_get(url, verify_ssl) { |get| digest_auth(get, response, username, password) }
        end
      else
        response = do_get(url, verify_ssl)
      end
      if response.code.to_i == 200
        response.body
      else
        raise Net::HTTPError.new("Error: got non-200 return code #{response.code} from #{url}, body = '#{response.body}'", nil)
      end
    end

    def prepend_scheme(uri)
      uri.prepend('http://') unless uri.match %r{\A\S+://}
      uri
    end

    private

    def http(uri, verify_ssl)
      Net::HTTP.new(uri.host, uri.port).tap do |http|
        if uri.scheme == 'https'
          http.use_ssl = true
          if verify_ssl
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          else
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          http.ca_file = File.join(File.expand_path(Rails.root), ConfigHelper.get(:certificate_bundle))
        end
        http.read_timeout = 30
        http.open_timeout = 30
      end
    end

    def do_get(url, verify_ssl)

      uri = URI.parse(prepend_scheme(url))
      get = Net::HTTP::Get.new("#{uri.path}?#{uri.query}")

      yield(get) if block_given?
      response = http(uri, verify_ssl).start { |web| web.request(get) }
      response
    rescue Errno::ECONNREFUSED
      raise Net::HTTPError.new("Error: Could not connect to the remote server", nil)
    end

    def digest_auth(get, response, username, password)
      challenge = HTTPAuth::Digest::Challenge.from_header(response['www-authenticate'])
      credentials = HTTPAuth::Digest::Credentials.from_challenge(challenge, {:username => username, :password => password, :uri => uri.path, :method => 'GET'})
      get['Authorization'] = credentials.to_header
    end

  end

end
