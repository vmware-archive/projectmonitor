class ProjectStatus < ActiveRecord::Base
  belongs_to :project

  validates :success, inclusion: { in: [true, false] }
  validates :build_id, presence: true

  scope :recent, -> {
    where.not(build_id: nil).order('published_at DESC, build_id DESC')
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
