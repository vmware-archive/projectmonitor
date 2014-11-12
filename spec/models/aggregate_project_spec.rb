require 'spec_helper'

describe AggregateProject, :type => :model do
  describe "factories" do
    describe "complete_aggregate_project" do
      let(:aggregate_project_with_project) { create(:aggregate_project_with_project) }

      it "should have a code" do
        expect(aggregate_project_with_project.code).not_to be_nil
      end

      it "should have a sub project" do
        expect(aggregate_project_with_project.projects).not_to be_empty
      end
    end
  end

  context "validations" do
    it { is_expected.to validate_presence_of :name }
  end

  let(:aggregate_project) { AggregateProject.new(name: "Aggregate Project") }

  it { is_expected.not_to be_tracker_project }

  describe "callbacks" do
    subject { aggregate_project }

    describe "before_destroy" do
      let(:project) { projects(:socialitis) }
      let!(:aggregate_project) { create :aggregate_project, projects: [project] }

      it "should remove its id from its projects" do
        expect(project.aggregate_project_id).not_to be_nil
        aggregate_project.destroy
        expect(project.reload.aggregate_project_id).to be_nil
      end
    end
  end

  describe "scopes" do
    describe "with_statuses" do
      it "returns only projects with statuses" do
        projects = AggregateProject.with_statuses
        expect(projects.length).to be > 0

        expect(projects).not_to include(aggregate_project)
        projects.each do |project|
          expect(project.status).not_to be_nil
        end
      end
    end

    describe ".displayable" do
      context "without tags" do
        let(:displayable_aggregate) { AggregateProject.displayable }

        it "should return enabled projects" do
          enabled  = create :aggregate_project_with_project, enabled: true
          disabled = create :aggregate_project_with_project, enabled: false

          expect(displayable_aggregate).to include enabled
          expect(displayable_aggregate).not_to include disabled
        end

        it "should not return aggregate projects that have no subprojects" do
          empty_aggregate = create :aggregate_project, enabled: true
          expect(displayable_aggregate).not_to include empty_aggregate
        end

        it "should not return duplicate aggregate projects" do
          enabled = create :aggregate_project, projects: [create(:project), create(:project)], enabled: true

          expect(displayable_aggregate.to_a.count(enabled)).to eq(1)
        end

        it "should return the projects in alphabetical order" do
          scope = double
          allow(AggregateProject).to receive_message_chain(:enabled,:joins,:select) { scope }
          expect(scope).to receive(:order).with('code ASC')
          AggregateProject.displayable
        end
      end

      context "when supplying tags" do
        let(:displayable_aggregate) { AggregateProject.displayable "red"}

        it "should return enabled projects with the requested tags" do
          disabled_red_project  = create :aggregate_project_with_project, enabled: false, tag_list: "red"
          disabled_blue_project = create :aggregate_project_with_project, enabled: false, tag_list: "blue"
          enabled_red_project   = create :aggregate_project_with_project, enabled: true, tag_list: "red"
          enabled_blue_project  = create :aggregate_project_with_project, enabled: true, tag_list: "blue"

          expect(displayable_aggregate).to include enabled_red_project
          expect(displayable_aggregate).not_to include disabled_red_project, disabled_blue_project, enabled_blue_project
        end

        it "should not return aggregate projects that have no subprojects" do
          red_empty_aggregate = create :aggregate_project, enabled: true, tag_list: "red"
          expect(displayable_aggregate).not_to include red_empty_aggregate
        end
      end
    end
  end

  describe "#code" do
    let(:project) { AggregateProject.new(name: "My Cool Project", code: code) }
    subject { project.code }

    context "code set but empty" do
      let(:code) { "" }
      it { is_expected.to eq("myco") }
    end

    context "code not set" do
      let(:code) { nil }
      it { is_expected.to eq("myco") }
    end

    context "code is set" do
      let(:code) { "code" }
      it { is_expected.to eq("code") }
    end
  end

  describe "#failure?" do
    it "should be red if one of its projects is red" do
      expect(aggregate_project).not_to be_failure
      aggregate_project.projects << projects(:red_currently_building)
      expect(aggregate_project).to be_failure
      aggregate_project.projects << projects(:green_currently_building)
      expect(aggregate_project).to be_failure
    end
  end

  describe "#success?" do
    it "should be success if all projects are success" do
      expect(aggregate_project).not_to be_success
      aggregate_project.projects << projects(:green_currently_building)
      expect(aggregate_project).to be_success
      aggregate_project.projects << projects(:pivots)
      expect(aggregate_project).to be_success
    end
  end

  describe "#indeterminate?" do
    context "aggregate project doesn't have any projects" do
      subject { AggregateProject.new.indeterminate? }
      it { is_expected.to be false }
    end

    context "aggregate has one yellow project " do
      subject do
        indeterminate_state = double(Project::State, to_s: "indeterminate", failure?: false, indeterminate?: true)
        project = Project.new
        allow(project).to receive(:state).and_return(indeterminate_state)
        AggregateProject.new(projects: [project]).indeterminate?
      end

      it { is_expected.to be true }
    end

    context "aggregate has one yellow and one red project " do
      subject do
        determinateProject = Project.new
        allow(determinateProject).to receive(:indeterminate?).and_return(true)
        indeterminateProject = Project.new
        allow(indeterminateProject).to receive(:indeterminate?).and_return(false)
        AggregateProject.new(projects: [determinateProject, indeterminateProject]).indeterminate?
      end
      
      it { is_expected.to be false }
    end
  end

  describe "#online?" do
    it "should not be online if any project not online" do
      expect(aggregate_project).not_to be_online
      aggregate_project.projects << projects(:socialitis)
      expect(aggregate_project).to be_online
      aggregate_project.projects << projects(:pivots)
      expect(aggregate_project).to be_online
      aggregate_project.projects << projects(:offline)
      expect(aggregate_project).not_to be_online
    end
  end

  describe '#status' do
    it "should return the last status of all the projects" do
      aggregate_project.projects << projects(:pivots)
      aggregate_project.projects << projects(:socialitis)
      expect(aggregate_project.status).to eq(projects(:socialitis).latest_status)
    end
  end

  describe '#building?' do
    it "should return the last status of all the projects" do
      aggregate_project.projects << projects(:pivots)
      aggregate_project.projects << projects(:socialitis)
      expect(aggregate_project).not_to be_building
      aggregate_project.projects << projects(:green_currently_building)
      expect(aggregate_project).to be_building
    end
  end

  describe '#recent_statuses' do
    it "should return the most recent statuses across projects" do
      aggregate_project.projects << projects(:pivots)
      aggregate_project.projects << projects(:socialitis)
      expect(aggregate_project.recent_statuses).to include project_statuses(:pivots_status)
      expect(aggregate_project.recent_statuses).to include project_statuses(:socialitis_status_green_01)
    end
  end

  describe "#statuses" do
    let(:aggregate_project) { aggregate_projects(:empty_aggregate) }

    it "return all latest_status of projects sorted by id, even if one of the project has no statuses" do
      aggregate_project.projects << projects(:socialitis)
      aggregate_project.projects << projects(:pivots)
      aggregate_project.projects << projects(:offline)
      aggregate_project.projects << Project.create(name: 'No status',
                                                   feed_url: 'http://ci.pivotallabs.com:3333/projects/pivots.rss')
      expect(aggregate_project.reload.statuses).to eq([projects(:pivots).latest_status,
                                                   projects(:socialitis).latest_status,
                                                   projects(:offline).latest_status,])
    end
  end

  describe "#red_since" do
    let(:aggregate_project) { aggregate_projects(:empty_aggregate) }

    it "returns #published_at for the red status after the most recent green status" do
      socialitis = projects(:socialitis)
      red_since = socialitis.red_since

      3.times do |i|
        socialitis.statuses.create!(success: false, build_id: i, published_at: Time.now + (i+1)*5.minutes )
      end

      aggregate_project.projects << socialitis

      expect(aggregate_project.reload.red_since).to eq(red_since)
    end

    it "should return nil if the project is currently green" do
      pivots = projects(:pivots)
      aggregate_project.projects << pivots
      expect(pivots).to be_success

      expect(pivots.red_since).to be_nil
    end

    it "should return the published_at of the first recorded status if the project has never been green" do
      project = projects(:never_green)
      aggregate_project.projects << project
      expect(aggregate_project.statuses.detect(&:success?)).to be_nil
      expect(aggregate_project.red_since).to eq(project.statuses.last.published_at)
    end

    it "should return nil if the project has no statuses" do
      @project = Project.new(name: "my_project_foo", feed_url: "http://foo.bar.com:3434/projects/mystuff/baz.rss")
      aggregate_project.projects << @project
      expect(aggregate_project.red_since).to be_nil
    end
  end

  describe "#red_build_count" do
    it "should return the number of red builds since the last green build" do
      project = projects(:socialitis)
      aggregate_project.projects << project
      expect(aggregate_project.red_build_count).to eq(1)

      project.statuses.create(success: false, build_id: 100)
      expect(aggregate_project.red_build_count).to eq(2)
    end

    it "should return zero for a green project" do
      project = projects(:pivots)
      aggregate_project.projects << project
      expect(aggregate_project).to be_success

      expect(aggregate_project.red_build_count).to eq(0)
    end

    it "should not blow up for a project that has never been green" do
      project = projects(:never_green)
      aggregate_project.projects << project
      expect(aggregate_project.red_build_count).to eq(aggregate_project.statuses.count)
    end
  end

  describe "#build" do
    context "when aggregate has no projects" do
      let(:aggregate) { create(:aggregate_project) }

      it "should return nil" do
        expect(aggregate.build).to be_nil
      end
    end

    context "when aggreaget has one project" do
      let(:aggregate) { create(:aggregate_project_with_project) }

      it "should return first project" do
        expect(aggregate.build).to eq(aggregate.projects.first)
      end
    end
  end

  describe "#breaking_build" do
    context "when a project does not have a published_at date" do
      it "should be ignored" do
        project = projects(:red_currently_building)
        other_project = create(:project)

        project.statuses.create(success: true, published_at: 1.day.ago, build_id: 100)
        status = project.statuses.create(success: false, published_at: 2.minutes.ago, build_id: 102)

        other_project.statuses.create(success: true, published_at: 1.day.ago, build_id: 101)
        bad_status = other_project.statuses.create(success: false, published_at: nil, build_id: 99)
        aggregate_project.projects << project
        aggregate_project.projects << other_project
        expect(aggregate_project.breaking_build).to eq(status)
      end
    end

    context "when one of the projects has never been green" do
      let(:never_been_green_project) { projects(:red_currently_building) }
      let(:once_been_green_project) { projects(:socialitis) }

      before do
        once_been_green_project.statuses.create(success: true, published_at: 1.day.ago, build_id: 101)
        @earliest_red_build_status = never_been_green_project.statuses.create(success: false, published_at: 2.days.ago, build_id: 102)

        aggregate_project.projects << never_been_green_project
        aggregate_project.projects << once_been_green_project
      end

      it "should return the earliest red build status" do
        expect(aggregate_project.breaking_build).to eq(@earliest_red_build_status)
      end
    end
  end

  describe "#destroy" do
    it "should orphan its children projects" do
      aggregate_project = aggregate_projects(:internal_projects_aggregate)
      project = aggregate_project.projects.first
      aggregate_project.destroy
      expect(Project.find(project.id).aggregate_project_id).to be(nil)
    end
  end
end
