require 'yaml'
aws_conf_location = File.expand_path('../../aws.yml', __FILE__)
ci_server = YAML.load_file(aws_conf_location)["ci_server"]['public_ip']

role :ci, ci_server