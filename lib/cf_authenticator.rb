class CF_authenticator
  def initialize

  end

  def authenticate_with(username,password,org,space)
      auth_result = `cf auth #{username} #{password}`
      if auth_result.include?("FAILED")
        puts 'Authentication failed, exiting'
        exit
      end
      auth_result = `cf t -o #{org} -s #{space}`
      if auth_result.include?("FAILED")
        puts 'Authentication failed, exiting'
        exit
      end
  end
end