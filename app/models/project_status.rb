class ProjectStatus < ActiveRecord::Base
  belongs_to :project

  validates :success, inclusion: { in: [true, false] }
  validates :build_id, presence: true

  scope :recent, -> (count = Project::RECENT_STATUS_COUNT) {
    rankings = <<-SQL.strip_heredoc
      SELECT   id,
      (CASE project_statuses.project_id
                  WHEN @curType
                  THEN @curRow := @curRow + 1
                  ELSE @curRow := 1 AND @curType := project_statuses.project_id END
               ) AS rank
      FROM     project_statuses,
               (SELECT @curRow := 0, @curType := '') r
      ORDER BY project_statuses.published_at desc, project_statuses.build_id desc
    SQL

    joins("INNER JOIN (#{rankings}) rankings ON rankings.id = project_statuses.id")
      .where("rankings.rank < :count", count: count + 1)
      .where.not(build_id: nil)
      .order(build_id: :desc, published_at: :desc)
  }

  scope :green, -> {
    where(success: true)
  }

  scope :red, -> {
    where(success: false)
  }

  def self.latest
    recent.first
  end

  def in_words
    success? ? 'success' : 'failure'
  end

end
