class TwitterSearch < ActiveRecord::Base
  validates_presence_of :search_term
  validates_uniqueness_of :search_term

  acts_as_taggable

  default_scope order('created_at asc')
end
