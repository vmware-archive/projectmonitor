class ProjectStatus < ActiveRecord::Base
  SUCCESS = 'success'
  FAILURE = 'failure'

  belongs_to :project

  validates :success, inclusion: { in: [true, false] }
  validates :build_id, presence: true

  def self.recent(projects, limit)
    where(project_id: Array(projects).map(&:id)).
      where('build_id IS NOT NULL').
      reverse_chronological.
      limit(limit)
  end

  def self.reverse_chronological
    order('build_id DESC')
  end

  def self.latest
    reverse_chronological.first
  end

  def self.green
    where(success: true)
  end

  def self.red
    where(success: false)
  end

  def in_words
    if success?
      SUCCESS
    else
      FAILURE
    end
  end
end
