class ConfigHelper
  def self.get(key)
    handle_value = ->(value) { block_given? ? yield(value) : value }

    key = key.to_s
    if ENV.key?(key)
      handle_value.(ENV[key] && YAML.load(ENV[key]))
    elsif Rails.configuration.respond_to?(key)
      handle_value.(Rails.configuration.send(key))
    end
  end
end
