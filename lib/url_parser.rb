class URLParser
  attr_accessor :type, :url

  def initialize(params, type)
    self.type = type.constantize
    self.url = @type.build_url_from_fields(params)
  end
end
