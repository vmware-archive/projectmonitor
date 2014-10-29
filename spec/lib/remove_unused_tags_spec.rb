require 'spec_helper'

describe RemoveUnusedTags::Job do
  describe "#perform" do
    let!(:project) { projects(:socialitis) }
    let!(:aggregate_project) { aggregate_projects(:internal_projects_aggregate) }

    before do
      ActsAsTaggableOn::Tag.destroy_all

      ActsAsTaggableOn::Tag.create!(name: "iamunused")
      project.tag_list.add("project-tag")
      project.save!
      aggregate_project.tag_list.add("aggregate-project-tag")
      aggregate_project.save!
    end

    it "removes unused tags" do
      RemoveUnusedTags::Job.new.perform
      remaining_tags = ActsAsTaggableOn::Tag.all.map(&:name)
      expect(remaining_tags).to match_array(['project-tag', 'aggregate-project-tag'])
    end
  end
end
