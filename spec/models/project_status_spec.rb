require 'spec_helper'

describe ProjectStatus do
  describe 'factories' do
    it 'should be valid project_status' do
      FactoryGirl.build(:project_status).should be_valid
    end
  end

  describe ".recent" do
    let(:project) { FactoryGirl.create(:jenkins_project) }
    let!(:status2) { project.statuses.create(build_id: 2, published_at: 3.years.ago) }
    let!(:status1) { project.statuses.create(build_id: 1, published_at: 2.years.ago) }

    context "for just one project" do
      it "returns statuses sorted by build id" do
        ProjectStatus.recent(project, 2).should == [status2, status1]
      end

      it "returns statuses that have a build_id" do
        status0 = project.statuses.create(build_id: nil, published_at: 1.year.ago)
        ProjectStatus.recent(project, 2).should_not include(status0)
      end

      it "returns a limited number of statuses" do
        ProjectStatus.recent(project, 1).size.should == 1
      end
    end

    context "for multiple projects" do
      let(:other_project) { FactoryGirl.create(:travis_project) }
      let!(:status3) { other_project.statuses.create(build_id: 3, published_at: 1.years.ago) }

      it "returns statuses for multiple projects" do
        ProjectStatus.recent([project, other_project], 3).should == [status3, status2, status1]
      end
    end
  end

  describe ".latest" do
    let(:project) { FactoryGirl.create(:jenkins_project) }
    let!(:status2) { project.statuses.create(build_id: 2, published_at: 3.years.ago) }
    let!(:status1) { project.statuses.create(build_id: 1, published_at: 2.years.ago) }

    it "returns the last status" do
      project.statuses.latest.should == status2
    end
  end

  describe "#in_words" do
    it "returns success for a successful status" do
      status = project_statuses(:socialitis_status_green_01)
      status.in_words.should == 'success'
    end

    it "returns failure for a failed status" do
      status = project_statuses(:socialitis_status_old_red_00)
      status.in_words.should == 'failure'
    end
  end
end
