# TODO: how to handle 401s?

class ConcourseAuthenticator
  def initialize(requester)
    @requester = requester
  end

  # Yields PollState, status code, session token or error message
  def authenticate(url, username, password)
    request_options = {}

    request_options[:head] = {'authorization' => [username, password]}

    request = @requester.initiate_request(url, request_options)
    if request
      request.callback do |client|
        case client.response_header.status
          when 200..299
            body = client.response
            json = JSON.parse(body)
            yield PollState::SUCCEEDED, client.response_header.status, json['value']
          else
            yield PollState::FAILED, client.response_header.status, 'authorization failed'
        end
      end

      request.errback do |client|
        yield PollState::FAILED, -1, 'network error'
      end
    else
      puts 'Error: Is your Concourse project set up correctly?'
      yield PollState::FAILED, -1, 'failed'
    end
  end
end