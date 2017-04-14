class ProjectStatus < ActiveRecord::Base
  belongs_to :project

  validates :success, inclusion: { in: [true, false] }
  validates :build_id, presence: true

  scope :recent, -> (count = Project::RECENT_STATUS_COUNT) {
    rankings = "SELECT id, RANK() OVER(PARTITION BY project_id ORDER BY published_at DESC, build_id DESC) rank FROM project_statuses"

    joins("INNER JOIN (#{rankings}) rankings ON rankings.id = project_statuses.id")
      .where("rankings.rank < :count", count: count + 1)
      .where.not(build_id: nil)
      .order(published_at: :desc, build_id: :desc)
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
