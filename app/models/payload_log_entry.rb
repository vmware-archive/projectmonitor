class PayloadLogEntry < ActiveRecord::Base
  belongs_to :project
  after_create :remove_duplicates

  default_scope { order('created_at DESC') }
  scope :reverse_chronological, -> () { order('created_at DESC') }

  def self.latest
    reverse_chronological.limit(1).first
  end

  def to_s
    "#{update_method} #{status}"
  end

  def remove_duplicates
    if status == 'failed'
      PayloadLogEntry.where(project_id: project_id).order(created_at: :asc).limit(2).each do |entry|
        if entry.id != id && entry.status == 'failed' && entry.error_text == error_text
          entry.delete()
        end
      end
    end
  end
end
