require 'spec_helper'

describe StatusController, :type => :controller do
  describe "#create" do

    context "Travis project" do
      let!(:project) { create(:travis_project) }
      let(:successful_payload) do
        URI.encode(open('spec/fixtures/travis_examples/success.json').read.gsub("4314974", "4219108"))
      end
      let(:failure_payload) do
        URI.encode(open('spec/fixtures/travis_examples/failure.json').read)
      end
      let(:on_start_payload) do
        URI.encode(open('spec/fixtures/travis_examples/created.json').read)
      end

      subject { post :create, project_id: project.guid, payload: successful_payload }

      it "should create a new status" do
        expect { subject }.to change(ProjectStatus, :count).by(1)
      end

      it "should log a payload log" do
        expect { subject }.to change(PayloadLogEntry, :count).by(1)
      end

      it "doesn't create new status recores for 'on_start' notifications" do
        expect {
          post :create, project_id: project.guid, payload: on_start_payload
        }.not_to change(ProjectStatus, :count)
      end

      it "also creates a new status when it receives successful notification after failure" do
        post :create, project_id: project.guid, payload: failure_payload

        expect {
          post :create, project_id: project.guid, payload: successful_payload
        }.to change { project.status.success }.from(false).to(true)
      end

      it "creates only one new status" do
        expect {
          subject
          subject
        }.to change(ProjectStatus, :count).by(1)
      end

      it "should have all the attributes" do
        post :create, project_id: project.guid, payload: failure_payload

        expect(ProjectStatus.last).not_to be_success
        expect(ProjectStatus.last.project_id).to eq(project.id)
        expect(ProjectStatus.last.published_at.to_s).to eq(Time.utc(2013, 1, 21, 16, 12, 15).to_s)
      end

      it "should update last_refreshed_at" do
        expect(project.last_refreshed_at).to be_nil
        subject
        expect(project.reload.last_refreshed_at).not_to be_nil
      end

      it "should update parsed_url" do
        expect(project.parsed_url).to be_nil
        subject
        expect(project.reload.parsed_url).to eq('https://travis-ci.org/account/project/builds/4219108')
      end
    end

    context "Jenkins project" do
      let!(:project) { create(:project) }
      let(:build_id) { 7 }
      let(:build_url) { "job/projectmonitor_ci_test/#{build_id}/" }
      let(:parsed_url) { "job/projectmonitor_ci_test/" }
      let(:payload) do
        %Q{{"name":"projectmonitor_ci_test",
        "url":"job/projectmonitor_ci_test/",
        "build":{"number":#{build_id},"phase":"FINISHED",
        "status":"FAILURE",
        "url":"#{build_url}"}}}
      end

      shared_examples_for "a Jenkins webhook build" do
        it "should create a new status" do
          expect { subject }.to change(ProjectStatus, :count).by(1)
        end

        it "creates only one new status" do
          expect {
            subject
            subject
          }.to change(ProjectStatus, :count).by(1)
        end

        it "should have all the attributes" do
          subject
          expect(ProjectStatus.last).not_to be_success
          expect(ProjectStatus.last.project_id).to eq(project.id)
          expect(ProjectStatus.last.build_id).to eq(build_id)
          expect(ProjectStatus.last.published_at).not_to be_nil
        end

        it "should update parsed_url" do
          expect(project.parsed_url).to be_nil
          subject
          expect(project.reload.parsed_url).to include parsed_url
        end
      end

      context "payload sent as raw post data (deprecated)" do
        subject do
          request.env['RAW_POST_DATA'] = payload
          post :create, project_id: project.guid
        end

        it_behaves_like "a Jenkins webhook build"
      end

      context "payload sent as params" do
        subject do
          post :create, JSON.parse(payload).merge(project_id: project.guid)
        end

        it_behaves_like "a Jenkins webhook build"
      end
    end

    context "Codeship project" do
      let!(:project) { create(:codeship_project, webhooks_enabled: true) }
      let(:payload)  { JSON.parse(open('spec/fixtures/codeship_examples/webhook.json').read) }
      subject { post :create, payload.merge(project_id: project.guid) }

      it "should create a new status" do
        expect { subject }.to change(ProjectStatus, :count).by(1)
      end

      it "creates only one new status" do
        expect {
          subject
          subject
        }.to change(ProjectStatus, :count).by(1)
      end
    end

    context "CircleCI project" do
      let(:payload)  { JSON.parse(open('spec/fixtures/circleci_examples/webhook.json').read) }

      subject { post :create, {project_id: project.guid} }

      before { @request.env['RAW_POST_DATA'] = payload.merge(project_id: project.guid).to_json }

      context 'when the update is for the blank branch' do
        let!(:project) { create(:circle_ci_project, webhooks_enabled: true, build_branch: '') }

        it "should create a new status" do
          expect { subject }.to change(ProjectStatus, :count).by(1)
        end

        it "creates only one new status" do
          expect {
            subject
            subject
          }.to change(ProjectStatus, :count).by(1)
        end

        it "should have all the attributes" do
          subject
          expect(ProjectStatus.last).to be_success
          expect(ProjectStatus.last.project_id).to eq(project.id)
          expect(ProjectStatus.last.build_id).to eq(2778736)
        end
      end

      context 'when the update is for the correct branch' do
        let!(:project) { create(:circle_ci_project, webhooks_enabled: true, build_branch: 'master') }

        it "should create a new status" do
          expect { subject }.to change(ProjectStatus, :count).by(1)
        end

        it "creates only one new status" do
          expect {
            subject
            subject
          }.to change(ProjectStatus, :count).by(1)
        end

        it "should have all the attributes" do
          subject
          expect(ProjectStatus.last).to be_success
          expect(ProjectStatus.last.project_id).to eq(project.id)
          expect(ProjectStatus.last.build_id).to eq(2778736)
        end
      end

      context 'when the update is for different branch' do
        let!(:project) { create(:circle_ci_project, webhooks_enabled: true, build_branch: 'feature') }

        it "should not create a new status" do
          expect { subject }.to_not change(ProjectStatus, :count)
        end

        it "does not create new status" do
          expect {
            subject
            subject
          }.to_not change(ProjectStatus, :count)
        end
      end
    end

    context "TeamCity Rest project" do
      let!(:project) { create(:team_city_rest_project) }
      let(:payload)  { JSON.parse(open('spec/fixtures/teamcity_json_examples/webhook.json').read) }

      subject do
        post :create, project_id: project.guid, build: payload
      end

      it "should create a new status" do
        expect { subject }.to change(ProjectStatus, :count).by(1)
      end

      it "creates only one new status" do
        expect {
          subject
          subject
        }.to change(ProjectStatus, :count).by(1)
      end

      it "should have all the attributes" do
        subject
        expect(ProjectStatus.last).to be_success
        expect(ProjectStatus.last.project_id).to eq(project.id)
        expect(ProjectStatus.last.build_id).to eq(13)
        expect(ProjectStatus.last.published_at).not_to be_nil
      end

      it "should update parsed_url" do
        expect(project.parsed_url).to be_nil
        subject
        expect(project.reload.parsed_url).to include 'bt2'
      end
    end

    context 'when processing the payload succeeded' do
      let(:project) { build(:jenkins_project, guid: '1')}

      let(:payload) do
        {'name'  => 'projectmonitor_ci_test',
         'url'    => 'job/projectmonitor_ci_test/',
         'build'  => {
           'number' => 7,
           'phase'  => 'FINISHED',
           'status' => 'FAILURE',
           'url'    => 'job/projectmonitor_ci_test/7/'}}
      end

      before do
        allow(Project).to receive(:find_by_guid).and_return(project)
      end

      after do
        post :create, payload.merge(project_id: project.guid)
      end

      it 'should set last_refreshed_at' do
        expect(project).to receive(:last_refreshed_at=)
      end

      it 'should save the project' do
        expect(project).to receive(:save!)
      end
    end

    context 'when processing the payload failed' do

      let(:project) { build(:jenkins_project, guid: '1')}

      before do
        allow(Project).to receive(:find_by_guid).and_return(project)
      end

      it "should not update the project's last_refreshed_at date" do
        expect(project).not_to receive(:last_refreshed_at=)

        expect{ post :create, project_id: project.guid, "payload" => 'invalid_post_content' }
          .to raise_error(ActionDispatch::ParamsParser::ParseError)
      end

    end

    context "when a project isn't found" do
      it "should return a 404" do
        post :create, project_id: "1234", "payload" => '{"id": 4219108}'
        expect(response.response_code).to eq(404)
      end
    end

  end
end
