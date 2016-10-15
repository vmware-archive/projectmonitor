class NetHttpBuilder
  def build(uri)
    Net::HTTP.new(uri.host, uri.port).tap do |http|
      if uri.scheme == 'https'
        http.use_ssl = true
        http.ca_file = Rails.root.join(ConfigHelper.get(:certificate_bundle)).to_s
      end
      http.read_timeout = 30
      http.open_timeout = 30
    end
  end
end