if !Rails.env.production?
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
end