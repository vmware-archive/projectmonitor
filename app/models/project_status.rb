class ProjectStatus < ActiveRecord::Base
  belongs_to :project

  SUCCESS = 'success'
  FAILURE = 'failure'
  OFFLINE = 'offline'

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
  
  private

  def all_attributes_match?(other)
    [:online, :success, :published_at, :url].all? do |attribute|
      other.send(attribute) == self.send(attribute)
    end
  end
end
