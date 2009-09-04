class LogEntry
  
  attr_reader :revision, :date_time, :message

  AUTOMATED_CHECKIN_MESSAGES = ['automated tagging', 'branched and frozen', 'Creating branch via rake task']

  def initialize(revision, date_time, message)
    @revision = revision
    @date_time = date_time
    @message = message
  end

  def automated?
    AUTOMATED_CHECKIN_MESSAGES.include?(@message)
  end
end
