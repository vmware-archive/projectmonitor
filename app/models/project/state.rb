class Project::State
  def initialize(online: false, success: nil)
    state_text = if !online
                   'offline'
                 elsif success == false
                   'failure'
                 elsif success
                   'success'
                 else
                   'indeterminate'
                 end
    @state = ActiveSupport::StringInquirer.new(state_text)
  end

  delegate :failure?, :success?, :indeterminate?, :offline?, :to_s, to: :state

  def self.success
    new(online: true, success: true)
  end

  def self.failure
    new(online: true, success: false)
  end

  def self.offline
    new(online: false, success: nil)
  end

  def self.indeterminate
    new(online: true, success: nil)
  end

  def online?
    !offline?
  end

  def color
    {
      'offline' => 'white',
      'success' => 'green',
      'failure' => 'red',
      'indeterminate' => 'yellow'
    }[state.to_s]
  end

  def eql?(other)
    to_s.eql?(other.to_s)
  end

  def hash
    to_s.hash
  end

  private

  attr_reader :state

end
