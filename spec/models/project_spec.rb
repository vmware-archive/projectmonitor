require 'spec_helper'

describe Project do
  let(:project) { FactoryGirl.build(:jenkins_project) }

  describe "factories" do
    it "should be valid for project" do
      FactoryGirl.build(:project).should be_valid
    end
  end

  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :type }
    it { should ensure_length_of(:location).is_at_most(20) }
  end

  describe "job queuing" do
    it "queues a higher priority job to fetch statuses for a newly created project" do
      project = FactoryGirl.build(:project)
      enqueued_job = double(:enqueued_job)

      StatusFetcher::Job.should_receive(:new).with(project).and_return(enqueued_job)
      Delayed::Job.should_receive(:enqueue).with(enqueued_job, priority: 1)

      project.save
    end
  end

  describe 'scopes' do
    describe "standalone" do
      it "should return non aggregated projects" do
        Project.standalone.should include projects(:pivots)
        Project.standalone.should include projects(:socialitis)
        Project.standalone.should_not include projects(:internal_project1)
        Project.standalone.should_not include projects(:internal_project2)
      end
    end

    describe "enabled" do
      let!(:disabled_project) { FactoryGirl.create(:jenkins_project, enabled: false) }

      it "should return only enabled projects" do
        Project.enabled.should include projects(:pivots)
        Project.enabled.should include projects(:socialitis)

        Project.enabled.should_not include disabled_project
      end
    end

    describe "with_statuses" do
      it "returns projects only with statues" do
        projects = Project.with_statuses

        projects.length.should > 9
        projects.should_not include project
        projects.each do |project|
          project.latest_status.should_not be_nil
        end
      end
    end

    describe "for_location" do
      let(:location) { "Jamaica" }
      let!(:included_project) { FactoryGirl.create(:jenkins_project, location: location) }
      let!(:excluded_project) { FactoryGirl.create(:jenkins_project, location: 'Elbonia') }

      subject { Project.for_location(location) }
      it { should include included_project }
      it { should_not include excluded_project }
    end

    describe "unknown_location" do
      let!(:included_project) { FactoryGirl.create(:jenkins_project, location: nil) }
      let!(:excluded_project) { FactoryGirl.create(:jenkins_project, location: 'Miami') }

      subject { Project.unknown_location }
      it { should include included_project }
      it { should_not include excluded_project }
    end

    describe '.displayable' do
      subject { Project.displayable tags }

      context "when supplying tags" do
        let(:tags) { "southeast, northwest" }

        it "should find tagged with tags" do
          scope = double
          Project.stub_chain(:standalone, :enabled) { scope }
          scope.should_receive(:find_tagged_with).with(tags)
          subject
        end

        context "when displayable projects are tagged" do
          before do
            projects(:socialitis).update_attributes(tag_list: tags)
            projects(:pivots).update_attributes(tag_list: [])
          end

          it "should return scoped projects" do
            subject.should include projects(:socialitis)
            subject.should_not include projects(:pivots)
          end
        end

      end

      context "when not supplying tags" do
        let(:tags) { nil }

        it "should return scoped projects" do
          subject.should include projects(:pivots)
          subject.should include projects(:socialitis)
        end
      end

    end

    describe "statuses" do
      let(:project) { projects(:socialitis) }

      it "should sort by newest to oldest" do
        project.statuses.should_not be_empty

        last_id = nil
        project.statuses.each do |status|
          status.id.should < last_id unless last_id.nil?
          last_id = status.id
        end
      end

    end

    describe "#code" do
      let(:project) { Project.new(name: "My Cool Project", code: code) }
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

    describe "#last green" do
      it "should return the successful project" do
        project = projects(:socialitis)
        project.statuses = []
        @happy_status = project.statuses.create!(:success => true)
        @sad_status = project.statuses.create!(:success => false)
        project.last_green.should == @happy_status
      end
    end

    describe "#status" do
      let(:project) { projects(:socialitis) }

      it "should return the most recent status" do
        project.status.should == project.statuses.find(:first)
      end
    end

    describe "#aggregate_project" do
      let(:project) { projects(:socialitis) }

      it "should have an aggregate project, if set" do
        project.aggregate_project.should be_nil
        @ap = AggregateProject.create(code:'ap', name:'ap')
        project.aggregate_project = @ap
        project.save.should be_true
        project = Project.find_by_name('Socialitis')
        project.aggregate_project.should == @ap
      end
    end

    describe "tracker integration" do
      let(:project) { Project.new }

      describe "#tracker_project?" do
        it "should return true if the project has a tracker_project_id and a tracker_auth_token" do
          project.tracker_project_id = double(:tracker_project_id)
          project.tracker_auth_token = double(:tracker_auth_token)
          project.tracker_project?.should be(true)
        end

        it "should return false if the project has a blank tracker_project_id AND a blank tracker_auth_token" do
          project.tracker_project_id = ""
          project.tracker_auth_token = ""
          project.tracker_project?.should be(false)
        end

        it "should return false if the project doesn't have tracker_project_id" do
          project.tracker_project?.should be(false)
        end

        it "should return false if the project doesn't have tracker_auth_token" do
          project.tracker_project?.should be(false)
        end
      end
    end

    describe "#red? and #green?" do
      it "should be true/false if the project's current status is not success" do
        project = projects(:socialitis)
        project.status.success.should be_false
        project.should be_red
        project.should_not be_green
      end

    it "should be false/true if the project's current status is success" do
      project = projects(:pivots)
      project.status.success.should be_true
      project.should_not be_red
      project.should be_green
    end

    it "should be false/false if the project has no statuses" do
      project.statuses.should be_empty
      project.should_not be_red
      project.should_not be_green
    end
    end

    describe "#latest_status" do
      let(:project) { FactoryGirl.create :project, name: "my_project" }

      let!(:recent_status_created_a_while_ago) { project.statuses.create(:success => true, :published_at => 5.minutes.ago, :created_at => 10.minutes.ago) }
      let!(:old_status_created_recently) { project.statuses.create(:success => true, :published_at => 20.minutes.ago, :created_at => 4.minutes.ago) }

      it "should return the most recent status" do
        project.latest_status.should == recent_status_created_a_while_ago
      end
    end

    describe "#red_since" do
      it "should return #published_at for the red status after the most recent green status" do
        project = projects(:socialitis)
        red_since = project.red_since

        3.times do |i|
          project.statuses.create!(:success => false, :published_at => Time.now + (i+1)*5.minutes)
        end

        project = Project.find(project.id)
        project.red_since.should == red_since
      end

      it "should return nil if the project is currently green" do
        project = projects(:pivots)
        project.should be_green

        project.red_since.should be_nil
      end

      it "should return the published_at of the first recorded status if the project has never been green" do
        project = projects(:never_green)
        project.statuses.detect(&:success?).should be_nil
        project.red_since.should == project.statuses.last.published_at
      end

      it "should return nil if the project has no statuses" do
        project.statuses.should be_empty
        project.red_since.should be_nil
      end
    end

    describe "#breaking build" do
      context "without any green builds" do
        it "should return the first red build" do
          project = projects(:socialitis)
          project.statuses.destroy_all
          first_red = project.statuses.create!(:success => false)
          project.statuses.create!(:success => false)
          project.statuses.create!(:success => false)
          project.breaking_build.should == first_red
        end
      end
    end

    describe "#red_build_count" do
      it "should return the number of red builds since the last green build" do
        project = projects(:socialitis)
        project.red_build_count.should == 1

        project.statuses.create(:success => false)
        project.red_build_count.should == 2
      end

      it "should return zero for a green project" do
        project = projects(:pivots)
        project.should be_green

        project.red_build_count.should == 0
      end

      it "should not blow up for a project that has never been green" do
        project = projects(:never_green)
        project.red_build_count.should == project.statuses.count
      end
    end

    describe "#enabled" do
      it "should be enabled by default" do
        project = Project.new
        project.should be_enabled
      end

      it "should store enabledness" do
        projects(:pivots).should be_enabled
        projects(:disabled).should_not be_enabled
      end
    end

    describe "#building?" do
      it "should be true if the project is currently building" do
        projects(:red_currently_building).should be_building
      end

      it "should return false for a project that is not currently building" do
        projects(:many_builds).should_not be_building
      end

      it "should return false for a project that has never been built" do
        projects(:never_built).should_not be_building
      end
    end
  end

  describe "#needs_poll?" do
    it "should return true if current time >= next_poll_at" do
      project.next_poll_at = 5.minutes.ago
      project.needs_poll?.should be_true
    end

    it "should return false when current time < next_poll_at" do
      project.next_poll_at = 5.minutes.from_now
      project.needs_poll?.should be_false
    end

    it "should return true if next_poll_at is null" do
      project.needs_poll?.should be_true
    end

  describe "#set_next_poll!" do
    epsilon = 2
    context "with a project poll interval set" do
      before do
        project.polling_interval = 25
      end

      it "should set the next_poll_at to Time.now + the project poll interval" do
        project.set_next_poll!
        (project.reload.next_poll_at - (Time.now + project.polling_interval)).abs.should <= epsilon
      end
    end

    context "without a project poll interval set" do
      it "should set the next_poll_at to Time.now + the system default interval" do
        project.set_next_poll!
        (project.reload.next_poll_at - (Time.now + Project::DEFAULT_POLLING_INTERVAL)).abs.should <= epsilon
      end
    end
  end

  describe "#has_auth?" do
    it "returns true if either username or password exists" do
      project.auth_username = "uname"
      project.has_auth?.should be_true

      project.auth_username = nil
      project.auth_password = "pwd"
      project.has_auth?.should be_true
    end

    it "returns false if both username and password are blank" do
      project.auth_username = ""
      project.auth_password = nil
      project.has_auth?.should be_false
    end
  end

  describe "#destroy" do
    it "should destroy related statuses" do
      project = projects(:pivots)
      project.statuses.count.should_not == 0
      status_id = project.statuses.first.id
      project.destroy
      proc { ProjectStatus.find(status_id)}.should raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe "validation" do
    it "has a valid Factory" do
      FactoryGirl.build(:project).should be_valid
    end
  end

  describe "#as_json" do
    subject { Project.new }

    it "should return only public attributes" do
      subject.as_json['project'].keys.should == ['id', :tag_list]
    end
  end

  describe '.project_specific_attributes' do
    subject { project_class.project_specific_attributes }

    context "when a CruiseControlProject" do
      let(:project_class) { CruiseControlProject }

      it { should =~ ['cruise_control_rss_feed_url'] }
    end

    context "when a JenkinsProject" do
      let(:project_class) { JenkinsProject }

      it { should =~ ['jenkins_base_url', 'jenkins_build_name'] }
    end

    context "when a TeamCityProject" do
      let(:project_class) { TeamCityProject }

      it { should =~ ['team_city_base_url', 'team_city_build_id'] }
    end

    context "when a TeamCityRestProject" do
      let(:project_class) { TeamCityRestProject }

      it { should =~ ['team_city_rest_base_url', 'team_city_rest_build_type_id'] }
    end

    context "when a TeamCityChainedProject" do
      let(:project_class) { TeamCityChainedProject }

      it { should =~ ['team_city_rest_base_url', 'team_city_rest_build_type_id'] }
    end

    context "when a TravisProject" do
      let(:project_class) { TravisProject }

      it { should =~ ['travis_github_account', 'travis_repository'] }
    end

    describe "#offline!" do
      it "marks a project as offline" do
        project = FactoryGirl.build :project, online: true
        project.should be_online

        project.offline!
        project.reload.should_not be_online
      end

      it "saves the project" do
        project = projects(:pivots)
        project.should_receive(:save!)
        project.offline!
      end
    end
  end

end
