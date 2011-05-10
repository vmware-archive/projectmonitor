ci_conf_location = File.expand_path('../../../../../ci.yml', __FILE__)
CI_CONFIG = YAML.load_file(ci_conf_location)