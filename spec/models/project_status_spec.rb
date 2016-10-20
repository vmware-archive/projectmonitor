require 'spec_helper'

describe ProjectStatus, :type => :model do
  let(:project)  { create(:jenkins_project) }
  let!(:status2) { project.statuses.create(build_id: 2, published_at: 3.years.ago) }
  let!(:status1) { project.statuses.create(build_id: 1, published_at: 2.years.ago) }

  describe ".recent" do
    context "for just one project" do
      it "returns statuses sorted by build_id and then published_at" do
        expect(project.statuses.recent).to eq([status2, status1])
      end

      it "returns statuses that have a build_id" do
        status0 = project.statuses.create(build_id: nil, published_at: 1.year.ago)
        expect(project.statuses.recent).not_to include(status0)
      end
    end
  end

  describe ".latest" do
    it "returns the last status" do
      expect(project.statuses.latest).to eq(status2)
    end
  end

  describe "#in_words" do
    it "returns success for a successful status" do
      status = project_statuses(:socialitis_status_green_01)
      expect(status.in_words).to eq('success')
    end

    it "returns failure for a failed status" do
      status = project_statuses(:socialitis_status_old_red_00)
      expect(status.in_words).to eq('failure')
    end
  end
end
