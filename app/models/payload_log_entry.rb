class PayloadLogEntry < ActiveRecord::Base
  belongs_to :project

  default_scope { order('created_at DESC') }
  scope :reverse_chronological, -> () { order('created_at DESC') }

  scope :recent, -> (count = 1) {
    rankings = "SELECT id, RANK() OVER(PARTITION BY project_id ORDER BY created_at DESC) rank FROM payload_log_entries"

    joins("INNER JOIN (#{rankings}) rankings ON rankings.id = payload_log_entries.id")
      .where("rankings.rank < :count", count: count + 1)
      .order(created_at: :desc)
  }

  def self.latest
    recent.first
  end

  def to_s
    "#{update_method} #{status}"
  end

end
