class ProjectStatus < ActiveRecord::Base
  SUCCESS = 'success'
  FAILURE = 'failure'
  OFFLINE = 'offline'

  belongs_to :project

  scope :online, lambda{ |projects, limit|
    where(:project_id => Array(projects).map(&:id), :online => true)
      .where('published_at is NOT NULL')
      .reverse_chronological
      .limit(limit)
  }

  scope :reverse_chronological, order('published_at DESC')

  def match?(status)
    if online?
      all_attributes_match?(status)
    else
      !status.online?
    end
  end

  def in_words
    if online?
      if success?
        SUCCESS
      else
        FAILURE
      end
    else
      OFFLINE
    end
  end

  private

  def all_attributes_match?(other)
    [:online, :success, :published_at, :url].all? do |attribute|
      other.send(attribute) == self.send(attribute)
    end
  end
end
