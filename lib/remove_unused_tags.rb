module RemoveUnusedTags
  class Job
    def perform
      tags = []
      Project.find_each do |project|
        tags << project.tag_list
      end
      tags.flatten!
      tags.uniq!
      Tag.find_each do |tag|
        tag.destroy unless tags.include?(tag.name)
      end
    end
  end
end
