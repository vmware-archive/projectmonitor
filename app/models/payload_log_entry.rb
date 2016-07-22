class PayloadLogEntry < ActiveRecord::Base
  belongs_to :project

  default_scope { order('created_at DESC') }
  scope :reverse_chronological, -> () { order('created_at DESC') }

  scope :recent, -> (count = 1) {
    rankings = <<-SQL.strip_heredoc
      SELECT   id,
      (CASE payload_log_entries.project_id
                  WHEN @curType
                  THEN @curRow := @curRow + 1
                  ELSE @curRow := 1 AND @curType := payload_log_entries.project_id END
               ) AS rank
      FROM     payload_log_entries,
               (SELECT @curRow := 0, @curType := '') r
      ORDER BY payload_log_entries.created_at desc
    SQL

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
