class PayloadLogEntry < ActiveRecord::Base
  belongs_to :project

  default_scope { order("created_at DESC") }
  scope :reverse_chronological, -> () { order("created_at DESC") }

  def self.latest
    reverse_chronological.limit(1).first
  end

  def to_s
    "#{update_method} #{status}"
  end
end
