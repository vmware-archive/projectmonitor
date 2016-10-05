require 'spec_helper'

describe Project, :type => :model do
  let(:project) { create(:jenkins_project) }

  describe 'associations' do
    it { is_expected.to have_many :statuses }
    it { is_expected.to have_many :payload_log_entries  }
    it { is_expected.to belong_to :aggregate_project }
    it { is_expected.to belong_to(:creator).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :type }
  end

  describe "callbacks" do
    let!(:count) {  Project::MAX_STATUS - 1 }

    before do
      project.statuses << create_list(:project_status, count, project: project)
    end
    context 'when the project is online' do
      let(:project) { build(:jenkins_project).tap {|p| p.online = true } }

      it 'should set the last_refreshed_at' do
        expect(project.last_refreshed_at).to be_present
      end

      context 'when the project is offline' do
        let(:project) { build(:jenkins_project) }

        it 'should not set the last_refreshed_at' do
          expect(project.last_refreshed_at).to be_nil
        end
      end
    end

    context "when feed urls have un-trimmed whitespaces" do
      it "trims semaphore urls" do
        url = "  http://example.com/feed.rss   "
        goal = "http://example.com/feed.rss"
        project = create(:semaphore_project, semaphore_api_url: url)
        expect(project.feed_url).to eq(goal)
      end

      it "trims circleci urls" do
        goal = "https://circleci.com/api/v1/project/white space/project/tree/master?circle-token=ABC"
        project = create(:circle_ci_project,
                                     circleci_username: "white space",
                                     ci_build_identifier: "project",
                                     ci_auth_token: "ABC   "
        )
        expect(project.feed_url).to eq(goal)
      end
    end
  end

  describe 'scopes' do
    describe "standalone" do
      it "should return non aggregated projects" do
        expect(Project.standalone).to include projects(:pivots)
        expect(Project.standalone).to include projects(:socialitis)
        expect(Project.standalone).not_to include projects(:internal_project1)
        expect(Project.standalone).not_to include projects(:internal_project2)
      end
    end

    describe "enabled" do
      let!(:disabled_project) { create(:jenkins_project, enabled: false) }

      it "should return only enabled projects" do
        expect(Project.enabled).to include projects(:pivots)
        expect(Project.enabled).to include projects(:socialitis)

        expect(Project.enabled).not_to include disabled_project
      end
    end

    describe "with_statuses" do
      it "returns projects only with statues" do
        projects = Project.with_statuses

        expect(projects.length).to be > 9
        expect(projects).not_to include project
        projects.each do |project|
          expect(project.latest_status).not_to be_nil
        end
      end
    end

    describe "with_aggregate_project" do
      subject do
        Project.with_aggregate_project(aggregate_projects(:internal_projects_aggregate)) do
          Project.all
        end
      end

      it { is_expected.to include projects(:internal_project1) }
      it { is_expected.not_to include projects(:socialitis) }
    end

    describe '.updateable' do
      subject { Project.updateable }

      let!(:enabled_webhooks_project) { create(:jenkins_project, enabled: true, webhooks_enabled: true) }
      let!(:disabled_webhooks_project) { create(:jenkins_project, enabled: false, webhooks_enabled: true) }
      let!(:disabled_polling_project) { create(:jenkins_project, enabled: false, webhooks_enabled: false) }
      let!(:enabled_polling_project) { create(:jenkins_project, enabled: true, webhooks_enabled: false) }
      let!(:enabled_nil_project) { create(:jenkins_project, enabled: true, webhooks_enabled: nil) }
      let!(:disabled_nil_project) { create(:jenkins_project, enabled: false, webhooks_enabled: nil) }

      it { is_expected.not_to include enabled_webhooks_project }
      it { is_expected.not_to include disabled_webhooks_project }
      it { is_expected.not_to include disabled_polling_project }
      it { is_expected.to include enabled_polling_project }
      it { is_expected.to include enabled_nil_project }
      it { is_expected.not_to include disabled_nil_project }
    end

    describe '.tracker_updateable' do
      subject { Project.tracker_updateable }

      let!(:updateable1) { create(:jenkins_project, tracker_auth_token: 'aafaf', tracker_project_id: '1') }
      let!(:updateable2) { create(:travis_project, tracker_auth_token: 'aafaf', tracker_project_id: '1') }
      let!(:not_updateable1) { create(:jenkins_project, tracker_project_id: '1') }
      let!(:not_updateable2) { create(:jenkins_project, tracker_auth_token: 'aafaf') }
      let!(:not_updateable3) { create(:travis_project, tracker_project_id: '', tracker_auth_token: '') }

      it { is_expected.to include updateable1 }
      it { is_expected.to include updateable2 }
      it { is_expected.not_to include not_updateable1 }
      it { is_expected.not_to include not_updateable2 }
      it { is_expected.not_to include not_updateable3 }
    end

    describe '.displayable' do
      subject { Project.displayable tags }

      context "when supplying tags" do
        let(:tags) { "southeast, northwest" }

        it "should find tagged with tags" do
          scope = double
          allow(Project).to receive_message_chain(:enabled, :order) { scope }
          expect(scope).to receive(:tagged_with).with(tags, {any: true})
          subject
        end

        context "when displayable projects are tagged" do
          before do
            projects(:socialitis).update_attributes(tag_list: tags)
            projects(:jenkins_project).update_attributes(tag_list: "southeast")
            projects(:pivots).update_attributes(tag_list: [])
          end

          it "should return scoped projects" do
            expect(subject).to include(projects(:socialitis), projects(:jenkins_project))
            expect(subject).not_to include projects(:pivots)
          end
        end

      end

      context "when not supplying tags" do
        let(:tags) { nil }

        it "should return scoped projects" do
          expect(subject).to include projects(:pivots)
          expect(subject).to include projects(:socialitis)
        end
      end

    end
  end

  describe "#code" do
    let(:project) { Project.new(name: "My Cool Project", code: code) }
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

  describe "#last green" do
    it "returns the successful project" do
      project = projects(:socialitis)
      project.statuses = []
      @happy_status = project.statuses.create!(success: true, build_id: 1)
      @sad_status = project.statuses.create!(success: false, build_id: 2)
      expect(project.last_green).to eq(@happy_status)
    end
  end

  describe "#status" do
    context "when project has statuses" do
      let(:project) { projects(:socialitis) }

      it "returns the most recent status" do
        expect(project.status).to eq(project.recent_statuses.first)
      end
    end

    context "when project has no statuses" do
      let(:project) { Project.new }

      it "returns new status" do
        expect(project.status.new_record?).to be true
      end

      it "returns new status associated with the project" do
        expect(project.status.project).to eq(project)
      end
    end
  end

  describe "tracker integration" do
    let(:project) { Project.new }

    describe "#tracker_project?" do
      it "should return true if the project has a tracker_project_id and a tracker_auth_token" do
        project.tracker_project_id = double(:tracker_project_id)
        project.tracker_auth_token = double(:tracker_auth_token)
        expect(project.tracker_project?).to be(true)
      end

      it "should return false if the project has a blank tracker_project_id AND a blank tracker_auth_token" do
        project.tracker_project_id = ""
        project.tracker_auth_token = ""
        expect(project.tracker_project?).to be(false)
      end

      it "should return false if the project doesn't have tracker_project_id" do
        expect(project.tracker_project?).to be(false)
      end

      it "should return false if the project doesn't have tracker_auth_token" do
        expect(project.tracker_project?).to be(false)
      end
    end
  end

  describe "#failure?, #success? and #indeterminate?" do
    subject { project }

    context "the project has a failure status" do
      let(:project) { create(:jenkins_project, online: true) }
      let!(:status) { ProjectStatus.create!(project: project, success: false, build_id: 1) }

      describe '#failure?' do
        subject { super().failure? }
        it { is_expected.to be true }
      end

      describe '#success?' do
        subject { super().success? }
        it { is_expected.to be false }
      end

      describe '#indeterminate?' do
        subject { super().indeterminate? }
        it { is_expected.to be false }
      end
    end

    context "the project has a success status" do
      let(:project) { create(:project, online: true) }
      let!(:status) { ProjectStatus.create!(project: project, success: true, build_id: 1) }

      describe '#failure?' do
        subject { super().failure? }
        it { is_expected.to be false }
      end

      describe '#success?' do
        subject { super().success? }
        it { is_expected.to be true }
      end

      describe '#indeterminate?' do
        subject { super().indeterminate? }
        it { is_expected.to be false }
      end
    end

    context "the project has no statuses" do
      let(:project) { Project.new(online: true) }

      describe '#failure?' do
        subject { super().failure? }
        it { is_expected.to be false }
      end

      describe '#success?' do
        subject { super().success? }
        it { is_expected.to be false }
      end

      describe '#indeterminate?' do
        subject { super().indeterminate? }
        it { is_expected.to be true }
      end
    end

    context "the project is offline" do
      let(:project) { Project.new(online: false) }

      describe '#failure?' do
        subject { super().failure? }
        it { is_expected.to be false }
      end

      describe '#success?' do
        subject { super().success? }
        it { is_expected.to be false }
      end

      describe '#indeterminate?' do
        subject { super().indeterminate? }
        it { is_expected.to be false }
      end
    end
  end

  describe "#latest_status" do
    let(:project) { create :project, name: "my_project" }
    let!(:status) { project.statuses.create(success: true, build_id: 1) }

    it "returns the most recent status" do
      expect(project.recent_statuses).to receive(:first)
      project.latest_status
    end
  end

  describe "#red_since" do
    it "should return #published_at for the red status after the most recent green status" do
      project = projects(:socialitis)
      red_since = project.red_since

      2.times do |i|
        project.statuses.create!(success: false, build_id: i, published_at: Time.now + (i+1)*5.minutes)
      end

      project = Project.find(project.id)
      expect(project.red_since).to eq(red_since)
    end

    it "should return nil if the project is currently succeeding" do
      project = projects(:pivots)
      expect(project).to be_success

      expect(project.red_since).to be_nil
    end

    it "should return the published_at of the first recorded status if the project has never been green" do
      project = projects(:never_green)
      expect(project.statuses.detect(&:success?)).to be_nil
      expect(project.red_since).to eq(project.statuses.last.published_at)
    end

    it "should return nil if the project has no statuses" do
      expect(project.statuses).to be_empty
      expect(project.red_since).to be_nil
    end

    describe "#breaking build" do
      context "without any green builds" do
        it "should return the first red build" do
          project = projects(:socialitis)
          project.statuses.destroy_all
          first_red = project.statuses.create!(success: false, build_id: 1, published_at: 3.minutes.ago)
          project.statuses.create!(success: false, build_id: 2, published_at: 2.minutes.ago)
          project.statuses.create!(success: false, build_id: 3, published_at: 1.minutes.ago)
          expect(project.breaking_build).to eq(first_red)
        end
      end
    end
  end

  describe "#breaking build" do
    context "without any green builds" do
      it "should return the first red build" do
        project = projects(:socialitis)
        expect(project.red_build_count).to eq(1)

        project.statuses.create!(success: false, build_id: 100)
        expect(project.red_build_count).to eq(2)
      end
    end
  end

  describe "#red_build_count" do
    it "should return the number of red builds since the last green build" do
      project = projects(:socialitis)
      expect(project.red_build_count).to eq(1)

      project.statuses.create(success: false, build_id: 100)
      expect(project.red_build_count).to eq(2)
    end

    it "should return zero for a green project" do
      project = projects(:pivots)
      expect(project).to be_success

      expect(project.red_build_count).to eq(0)
    end

    it "should not blow up for a project that has never been green" do
      project = projects(:never_green)
      expect(project.red_build_count).to eq(project.statuses.count)
    end
  end

  describe "#enabled" do
    it "should be enabled by default" do
      project = Project.new
      expect(project).to be_enabled
    end

    it "should store enabledness" do
      expect(projects(:pivots)).to be_enabled
      expect(projects(:disabled)).not_to be_enabled
    end
  end

  describe "#has_auth?" do
    it "returns true if either username or password exists" do
      project.auth_username = "uname"
      expect(project.has_auth?).to be true

      project.auth_username = nil
      project.auth_password = "pwd"
      expect(project.has_auth?).to be true
    end

    it "returns false if both username and password are blank" do
      project.auth_username = ""
      project.auth_password = nil
      expect(project.has_auth?).to be false
    end
  end

  describe "#destroy" do
    it "should destroy related statuses" do
      project = projects(:pivots)
      expect(project.statuses.count).not_to eq(0)
      status_id = project.statuses.first.id
      project.destroy
      expect { ProjectStatus.find(status_id)}.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe "validation" do
    it "has a valid Factory" do
      expect(build(:project)).to be_valid
    end
  end

  describe '.project_specific_attributes' do
    subject { project_class.project_specific_attributes }

    context "when a CruiseControlProject" do
      let(:project_class) { CruiseControlProject }

      it { is_expected.to match_array(['cruise_control_rss_feed_url']) }
    end

    context "when a JenkinsProject" do
      let(:project_class) { JenkinsProject }

      it { is_expected.to match_array(['ci_base_url', 'ci_build_identifier']) }
    end

    context "when a TeamCityProject" do
      let(:project_class) { TeamCityProject }

      it { is_expected.to match_array(['ci_base_url', 'ci_build_identifier']) }
    end

    context "when a TeamCityRestProject" do
      let(:project_class) { TeamCityRestProject }

      it { is_expected.to match_array(['ci_base_url', 'ci_build_identifier']) }
    end

    context "when a TravisProject" do
      let(:project_class) { TravisProject }

      it { is_expected.to match_array(['travis_github_account', 'travis_repository']) }
    end

    context "when a TravisProProject" do
      let(:project_class) { TravisProProject }

      it { is_expected.to match_array(['travis_github_account', 'travis_repository', 'ci_auth_token']) }
    end

    context "when a ConcourseV1Project" do
      let(:project_class) { ConcourseV1Project }

      it { is_expected.to match_array(['ci_base_url', 'ci_build_identifier', 'concourse_pipeline_name']) }
    end

    context "when a CircleCiProject" do
      let(:project_class) { CircleCiProject }

      it { is_expected.to match_array(['circleci_username', 'ci_build_identifier', 'ci_auth_token']) }
    end

    context "when a SemaphoreProject" do
      let(:project_class) { SemaphoreProject }

      it { is_expected.to match_array(['semaphore_api_url']) }
    end

    context "when a TddiumProject" do
      let(:project_class) { TddiumProject }

      it { is_expected.to match_array(['ci_build_identifier', 'ci_base_url', 'ci_auth_token']) }
    end
  end

  describe "#has_status?" do
    subject { project.has_status?(status) }

    let(:project) { projects(:socialitis) }

    context "when the project has the status" do
      let!(:status) { project.statuses.create!(build_id: 99) }
      it { is_expected.to be true }
    end

    context "when the project does not have the status" do
      let!(:status) { ProjectStatus.create!(build_id: 99) }
      it { is_expected.to be false }
    end
  end

  describe "#generate_guid" do
    let(:project) { build(:project) }

    it "calls generate_guid" do
      expect(project).to receive :generate_guid
      project.save!
    end

    it "generates random GUID" do
      project.save!
      expect(project.guid).not_to be_nil
      expect(project.guid).not_to be_empty
    end
  end

  describe "#populate_iteration_story_state_counts" do
    let(:project) { build(:project) }

    it "initializes iteration_story_state_counts to an empty array" do
      project.populate_iteration_story_state_counts
      expect(project.iteration_story_state_counts).to eq([])
    end

    it "calls populate_iteration_story_state_counts on create" do
      expect(project).to receive :populate_iteration_story_state_counts
      project.save!
    end
  end

  describe "#published_at" do
    subject { project.published_at }
    let(:project) { create(:project)}

    context "when there is a latest status" do
      let(:status) { build(:project_status, published_at: 5.minutes.ago) }
      before { project.statuses << status }

      it "returns the time the status was published" do
        expect(subject.to_i).to eq(status.published_at.to_i)
      end
    end

    context "when there are no statuses" do
      it { is_expected.to be_nil }
    end
  end

  describe '#iteration_story_state_counts' do
    it 'defaults to an empty hash' do
      subject = described_class.new

      expect(subject.iteration_story_state_counts).to eq({})

      subject.iteration_story_state_counts = { a: 2 }

      expect(subject.iteration_story_state_counts).to eq({'a' => 2})
    end
  end

  it "has a webhook_payload method" do
    Project.subclasses.each { |project_class|
      expect(project_class.method_defined? :webhook_payload).to be(true), "#{project_class} is a Project subclass that does not have a required 'webhook_payload' method defined."
    }
  end
end
