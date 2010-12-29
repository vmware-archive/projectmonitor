require 'rake'

class Rake::Task
  def overwrite(&block)
    @actions.clear
    prerequisites.clear
    enhance(&block)
  end
  def abandon
    prerequisites.clear
    @actions.clear
  end
end
