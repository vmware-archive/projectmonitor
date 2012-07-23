class ProjectStatus < ActiveRecord::Base
  SUCCESS = 'success'
  FAILURE = 'failure'

  belongs_to :project

  scope :recent, lambda{ |projects, limit|
    where(:project_id => Array(projects).map(&:id))
    .where('published_at is NOT NULL')
    .reverse_chronological
    .limit(limit)
  }

  scope :reverse_chronological, order('published_at DESC')

  def match?(status)
    all_attributes_match?(status)
  end

  def in_words
    if success?
      SUCCESS
    else
      FAILURE
    end
  end

  private

  def all_attributes_match?(other)
    [:success, :published_at, :url].all? do |attribute|
      other.send(attribute) == self.send(attribute)
    end
  end
end
