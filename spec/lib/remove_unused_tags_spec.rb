require 'spec_helper'

describe RemoveUnusedTags::Job do
  describe "#perform" do
    let!(:project_with_tags) { projects(:socialitis) }
    let!(:dead_tag) { ActsAsTaggableOn::Tag.create!(name: "iamunused") }

    it "removes unused tags" do
      RemoveUnusedTags::Job.new.perform
      remaining_tags = ActsAsTaggableOn::Tag.all.map(&:name)
      project_with_tags.tag_list.each do |tag|
        remaining_tags.should include(tag)
      end
      remaining_tags.should_not include(dead_tag.name)
    end

  end
end
