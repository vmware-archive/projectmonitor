# TODO: how to handle 401s?

class ConcourseAuthenticator
  def initialize(requester)
    @requester = requester
  end

  def authenticate(url, username, password)
    request_options = {}

    request_options[:head] = {'authorization' => [username, password]}

    request = @requester.initiate_request(url, request_options)
    if request
      request.callback do |client|
        body = client.response
        json = JSON.parse(body)
        yield json['value']
      end

      request.errback do |client|
        # do we actually want to yield this?
        yield PollState::FAILED, client.error
      end
    else
      puts 'Error: Is your Concourse project set up correctly?'
    end
  end
end