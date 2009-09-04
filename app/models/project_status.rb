class ProjectStatus < ActiveRecord::Base
  belongs_to :project

  SUCCESS = 'success'
  FAILURE = 'failure'
  OFFLINE = 'offline'

  def match?(hash)
    if self.online
      all_attributes_match?(hash)
    else
      !hash[:online]
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

  def all_attributes_match?(hash)
    [:online, :success, :published_at, :url].all? do |attribute|
      hash[attribute] == self.send(attribute)
    end
  end
end
