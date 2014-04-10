require 'spec_helper'

describe AggregateProject do
  describe "factories" do
    describe "complete_aggregate_project" do
      let(:aggregate_project_with_project) { create(:aggregate_project_with_project) }

      it "should have a name" do
        aggregate_project_with_project.name.should_not be_nil
      end

      it "should have a code" do
        aggregate_project_with_project.code.should_not be_nil
      end

      it "should be valid" do
        aggregate_project_with_project.should be_valid
      end

      it "should have a sub project" do
        aggregate_project_with_project.projects.should_not be_empty
      end
    end
  end

  context "validations" do
    it { should validate_presence_of :name }
    it "has a valid Factory" do
      FactoryGirl.build(:aggregate_project).should be_valid
    end
  end

  let(:aggregate_project) { AggregateProject.new(name: "Aggregate Project") }

  it { should_not be_tracker_project }

  describe "callbacks" do
    subject { aggregate_project }

    describe "before_destroy" do
      let(:project) { projects(:socialitis) }
      let!(:aggregate_project) { FactoryGirl.create :aggregate_project, :projects => [project] }

      it "should remove its id from its projects" do
        project.aggregate_project_id.should_not be_nil
        aggregate_project.destroy
        project.reload.aggregate_project_id.should be_nil
      end
    end
  end

  describe "scopes" do
    describe "with_statuses" do
      before do
        aggregate_project.save!
      end

      it "returns only projects with statuses" do
        projects = AggregateProject.with_statuses
        projects.length.should > 0

        projects.should_not include(aggregate_project)
        projects.each do |project|
          project.status.should_not be_nil
        end
      end
    end

    describe ".displayable" do
      context "without tags" do
        let(:displayable_aggregate) { AggregateProject.displayable }

        it "should return enabled projects" do
          enabled = FactoryGirl.create :aggregate_project, :projects => [create(:project)], enabled: true
          disabled = FactoryGirl.create :aggregate_project, :projects => [create(:project)], enabled: false

          displayable_aggregate.should include enabled
          displayable_aggregate.should_not include disabled
        end

        it "should not return aggregate projects that have no subprojects" do
          empty_aggregate = create :aggregate_project, enabled: true
          displayable_aggregate.should_not include empty_aggregate
        end

        it "should not return duplicate aggregate projects" do
          enabled = FactoryGirl.create :aggregate_project, :projects => [create(:project), create(:project)], enabled: true

          displayable_aggregate.to_a.count(enabled).should == 1
        end

        it "should return the projects in alphabetical order" do
          scope = double
          AggregateProject.stub_chain(:enabled,:joins,:select) { scope }
          scope.should_receive(:order).with('code ASC')
          AggregateProject.displayable
        end
      end

      context "when supplying tags" do
        let(:displayable_aggregate) { AggregateProject.displayable "red"}

        it "should return enabled projects with the requested tags" do
          disabled_red_project = FactoryGirl.create :aggregate_project, :projects => [create(:project)], enabled: false, tag_list: "red"
          disabled_blue_project = FactoryGirl.create :aggregate_project, :projects => [create(:project)], enabled: false, tag_list: "blue"
          enabled_red_project = FactoryGirl.create :aggregate_project, :projects => [create(:project)], enabled: true, tag_list: "red"
          enabled_blue_project = FactoryGirl.create :aggregate_project, :projects => [create(:project)], enabled: true, tag_list: "blue"

          displayable_aggregate.should include enabled_red_project
          displayable_aggregate.should_not include disabled_red_project, disabled_blue_project, enabled_blue_project
        end

        it "should not return aggregate projects that have no subprojects" do
          red_empty_aggregate = create :aggregate_project, enabled: true, tag_list: "red"
          displayable_aggregate.should_not include red_empty_aggregate
        end
      end
    end

    describe '.tagged' do
      subject { AggregateProject.tagged tags }

      let!(:tagged_project) { FactoryGirl.create :aggregate_project, :projects => [projects(:pivots)], enabled: true }
      let!(:untagged_project) { FactoryGirl.create :aggregate_project, :projects => [projects(:socialitis)], enabled: true }
      let!(:disabled_project) { FactoryGirl.create :aggregate_project, :projects => [projects(:internal_project1)], enabled: false }

      context "when supplying tags" do
        let(:tags) { "southeast, northwest" }

        it "should find tagged with tags" do
          AggregateProject.should_not_receive(:enabled)
          subject
        end

        context "when displayable projects are tagged" do
          before do
            tagged_project.update_attributes(tag_list: tags)
            disabled_project.update_attributes(tag_list: tags)
            untagged_project.update_attributes(tag_list: [])
          end

          it "should return scoped projects" do
            subject.should include tagged_project
            subject.should include disabled_project
            subject.should_not include untagged_project
          end
        end
      end

      context "when not supplying tags" do
        let(:tags) { nil }

        it "should return scoped projects" do
          subject.should include tagged_project
          subject.should include disabled_project
          subject.should include untagged_project
        end
      end
    end
  end

  describe "#code" do
    let(:project) { AggregateProject.new(name: "My Cool Project", code: code) }
    subject { project.code }

    context "code set but empty" do
      let(:code) { "" }
      it { should == "myco" }
    end

    context "code not set" do
      let(:code) { nil }
      it { should == "myco" }
    end

    context "code is set" do
      let(:code) { "code" }
      it { should == "code" }
    end
  end

  describe "#failure?" do
    it "should be red if one of its projects is red" do
      aggregate_project.should_not be_failure
      aggregate_project.projects << projects(:red_currently_building)
      aggregate_project.should be_failure
      aggregate_project.projects << projects(:green_currently_building)
      aggregate_project.should be_failure
    end
  end

  describe "#success?" do
    it "should be success if all projects are success" do
      aggregate_project.should_not be_success
      aggregate_project.projects << projects(:green_currently_building)
      aggregate_project.should be_success
      aggregate_project.projects << projects(:pivots)
      aggregate_project.should be_success
    end
  end

  describe "#indeterminate?" do
    context "aggregate project doesn't have any projects" do
      subject { AggregateProject.new.indeterminate? }
      it { should be_false }
    end

    context "aggregate has one yellow project " do
      subject do
        indeterminate_state = double(Project::State, to_s: "indeterminate", failure?: false, indeterminate?: true)
        project = Project.new.tap{|p| p.stub(state: indeterminate_state)}
        AggregateProject.new(:projects => [project]).indeterminate?
      end

      it { should be_true }
    end

    context "aggregate has one yellow and one red project " do
      subject do
        AggregateProject.new(:projects => [
          Project.new.tap{|p| p.stub(indeterminate?: true)},
          Project.new.tap{|p| p.stub(indeterminate?: false)}]).indeterminate?
      end
      it { should be_false }
    end
  end

  describe "#online?" do
    it "should not be online if any project not online" do
      aggregate_project.should_not be_online
      aggregate_project.projects << projects(:socialitis)
      aggregate_project.should be_online
      aggregate_project.projects << projects(:pivots)
      aggregate_project.should be_online
      aggregate_project.projects << projects(:offline)
      aggregate_project.should_not be_online
    end
  end

  describe '#status' do
    it "should return the last status of all the projects" do
      aggregate_project.projects << projects(:pivots)
      aggregate_project.projects << projects(:socialitis)
      aggregate_project.status.should == projects(:socialitis).latest_status
    end
  end

  describe '#building?' do
    it "should return the last status of all the projects" do
      aggregate_project.projects << projects(:pivots)
      aggregate_project.projects << projects(:socialitis)
      aggregate_project.should_not be_building
      aggregate_project.projects << projects(:green_currently_building)
      aggregate_project.should be_building
    end
  end

  describe '#recent_statuses' do
    it "should return the most recent statuses across projects" do
      aggregate_project.projects << projects(:pivots)
      aggregate_project.projects << projects(:socialitis)
      aggregate_project.recent_statuses.should include project_statuses(:pivots_status)
      aggregate_project.recent_statuses.should include project_statuses(:socialitis_status_green_01)
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
      aggregate_project.reload.statuses.should == [projects(:pivots).latest_status,
                                                   projects(:socialitis).latest_status,
                                                   projects(:offline).latest_status,]
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

      aggregate_project.reload.red_since.should == red_since
    end

    it "should return nil if the project is currently green" do
      pivots = projects(:pivots)
      aggregate_project.projects << pivots
      pivots.should be_success

      pivots.red_since.should be_nil
    end

    it "should return the published_at of the first recorded status if the project has never been green" do
      project = projects(:never_green)
      aggregate_project.projects << project
      aggregate_project.statuses.detect(&:success?).should be_nil
      aggregate_project.red_since.should == project.statuses.last.published_at
    end

    it "should return nil if the project has no statuses" do
      @project = Project.new(:name => "my_project_foo", :feed_url => "http://foo.bar.com:3434/projects/mystuff/baz.rss")
      aggregate_project.projects << @project
      aggregate_project.red_since.should be_nil
    end
  end

  describe "#red_build_count" do
    it "should return the number of red builds since the last green build" do
      project = projects(:socialitis)
      aggregate_project.projects << project
      aggregate_project.red_build_count.should == 1

      project.statuses.create(success: false, build_id: 100)
      aggregate_project.red_build_count.should == 2
    end

    it "should return zero for a green project" do
      project = projects(:pivots)
      aggregate_project.projects << project
      aggregate_project.should be_success

      aggregate_project.red_build_count.should == 0
    end

    it "should not blow up for a project that has never been green" do
      project = projects(:never_green)
      aggregate_project.projects << project
      aggregate_project.red_build_count.should == aggregate_project.statuses.count
    end
  end

  describe "#build" do
    context "when aggregate has no projects" do
      let(:aggregate) { create(:aggregate_project) }

      it "should return nil" do
        aggregate.build.should be_nil
      end
    end

    context "when aggreaget has one project" do
      let(:aggregate) { create(:aggregate_project_with_project) }

      it "should return first project" do
        aggregate.build.should == aggregate.projects.first
      end
    end
  end

  describe "#breaking_build" do
    context "when a project does not have a published_at date" do
      it "should be ignored" do
        project = projects(:red_currently_building)
        other_project = FactoryGirl.create(:project)

        project.statuses.create(success: true, published_at: 1.day.ago, build_id: 100)
        status = project.statuses.create(success: false, published_at: 2.minutes.ago, build_id: 102)

        other_project.statuses.create(success: true, published_at: 1.day.ago, build_id: 101)
        bad_status = other_project.statuses.create(success: false, published_at: nil, build_id: 99)
        aggregate_project.projects << project
        aggregate_project.projects << other_project
        aggregate_project.breaking_build.should == status
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
        aggregate_project.breaking_build.should == @earliest_red_build_status
      end
    end
  end

  describe "#destroy" do
    it "should orphan its children projects" do
      aggregate_project = aggregate_projects(:internal_projects_aggregate)
      project = aggregate_project.projects.first
      aggregate_project.destroy
      Project.find(project.id).aggregate_project_id.should be(nil)
    end
  end

  describe "#status_in_words" do
    subject { aggregate.status_in_words }

    let(:aggregate) { FactoryGirl.build(:aggregate_project) }

    context "when there's a project failing" do
      before do
        failing_state = double(Project::State, to_s: "failure", failure?: true)
        failing_project = Project.new.tap { |p| p.stub(state: failing_state) }
        non_failing_project = Project.new.tap { |p| p.stub_chain(:state, :failure?).and_return(false) }
        aggregate.projects = [failing_project, non_failing_project]
      end

      it { should == "failure" }
    end

    context "when all projects are succeeding" do
      before do
        success_state = double(Project::State, to_s: "success", failure?: false)
        succeeding_project1 = Project.new.tap { |p| p.stub(state: success_state) }
        succeeding_project2 = Project.new.tap { |p| p.stub(state: success_state) }
        aggregate.projects = [succeeding_project1, succeeding_project2]
      end

      it { should == "success" }
    end

    context "when all the projects are indeterminate" do
      before do
        indeterminate_state = double(Project::State, to_s: "indeterminate", failure?: false)
        indeterminate_project1 = Project.new.tap { |p| p.stub(state: indeterminate_state) }
        indeterminate_project2 = Project.new.tap { |p| p.stub(state: indeterminate_state) }
        aggregate.projects = [indeterminate_project1, indeterminate_project2]
      end

      it { should == "indeterminate" }
    end

    context "when a project is offline it is offline" do
      before do
        offline_state = double(Project::State, to_s: "offline", failure?: false)
        success_state = double(Project::State, to_s: "success", failure?: false)

        offline_project = Project.new.tap { |p| p.stub(state: offline_state, online?: false) }
        succeeding_project = Project.new.tap { |p| p.stub(state: success_state, online?: true) }
        aggregate.projects = [offline_project, succeeding_project]
      end

      it { should == "offline" }
    end

    context "when none of the above it is indeterminate" do
      before do
        indeterminate_state = double(Project::State, to_s: "indeterminate", failure?: false)
        success_state = double(Project::State, to_s: "success", failure?: false)
        indeterminate_project = Project.new.tap { |p| p.stub(state: indeterminate_state, online?: true) }
        succeeding_project = Project.new.tap { |p| p.stub(state: success_state, online?: true) }
        aggregate.projects = [indeterminate_project, succeeding_project]
      end

      it { should == "indeterminate" }
    end
  end
end
