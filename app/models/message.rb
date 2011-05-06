class Message < ActiveRecord::Base
  DURATIONS_SELECT = [
    ["30 minutes", 30.minutes],
    ["1 hour",     1.hour],
    ["2 hours",    2.hours],
    ["8 hours",    8.hours],
    ["1 day",      1.day],
    ["2 days",     2.days]
  ]

  validates_presence_of :text

  after_create :set_expires_at

  acts_as_taggable

  default_scope order('created_at asc')
  scope :active, lambda { where("expires_at IS NULL OR expires_at >= ?", Time.now) }

  def expires_in
    return if expires_at.blank?
    return if created_at.blank?

    expires_at - created_at
  end

  def expires_in=(seconds)
    if seconds.to_i > 0
      @expires_in = seconds.to_i
      self.expires_at = (created_at || Time.now) + @expires_in
    end
  end

  private

  def set_expires_at
    return unless @expires_in

    update_attribute(:expires_at, created_at + @expires_in)
  end
end
