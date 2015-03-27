class CF_authenticator
  def initialize

  end

  def authenticate_with(username,password)
      authResult = `cf auth #{username} #{password}`
      if authResult.include?("FAILED")
        puts 'Authentication failed, exiting'
        exit
      end
      authResult = `cf t -o pivotallabs -s project-monitor`
      if authResult.include?("FAILED")
        puts 'Authentication failed, exiting'
        exit
      end
  end
end