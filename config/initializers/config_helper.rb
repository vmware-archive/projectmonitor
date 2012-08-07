def config_for(key, required = false)
  handle_value = ->(value) { block_given? ? yield(value) : value }

  key = key.to_s
  if ENV.key?(key)
    handle_value.(ENV[key])
  elsif Rails.configuration.respond_to?(key)
    handle_value.(Rails.configuration.send(key))
  elsif required
    raise ArgumentError.new "Missing required configuration parameter '#{key}'"
  end
end
