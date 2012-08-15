class ConfigHelper
  def self.get(key)
    handle_value = ->(value) { block_given? ? yield(value) : value }

    key = key.to_s
    if ENV.key?(key)
      ENV[key] == "false" ? v = false : v = ENV[key]
      handle_value.(v)
    elsif Rails.configuration.respond_to?(key)
      handle_value.(Rails.configuration.send(key))
    end
  end
end
