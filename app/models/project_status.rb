class ProjectStatus < ActiveRecord::Base
  belongs_to :project

  validates :success, inclusion: { in: [true, false] }
  validates :build_id, presence: true

  scope :recent, ->(projects, limit) {
    where(project_id: Array(projects).map(&:id)).reverse_chronological.limit(limit)
  }

  scope :reverse_chronological, -> {
    where('build_id IS NOT NULL').order('published_at DESC, build_id DESC')
  }

  scope :green, -> {
    where(success: true)
  }

  scope :red, -> {
    where(success: false)
  }

  class << self
    def latest
      reverse_chronological.first
    end
  end

  def in_words
    if success?
      'success'
    else
      'failure'
    end
  end

end
