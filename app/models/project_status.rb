class ProjectStatus < ActiveRecord::Base

  SUCCESS = 'success'
  FAILURE = 'failure'
  OFFLINE = 'offline'

  belongs_to :project

  scope :online, lambda{ |*args|
    count = args.slice!(-1)
    project_ids = args.flatten.collect {|p| p.id }
    where(:project_id => project_ids, :online => true).where('published_at is NOT NULL').order('published_at DESC').limit(count)
  }

  after_create :become_project_latest_status

  def match?(status)
    if self.online
      all_attributes_match?(status)
    else
      !status.online
    end
  end
  
  def in_words
    if self.online
      if self.success
        return SUCCESS
      else
        return FAILURE
      end
    else
      return OFFLINE
    end
  end

  def become_project_latest_status
    project.update_attributes!(:latest_status => self)
  end

  private

  def all_attributes_match?(other)
    [:online, :success, :published_at, :url].all? do |attribute|
      other.send(attribute) == self.send(attribute)
    end
  end
end
