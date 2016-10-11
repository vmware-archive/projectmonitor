require 'spec_helper'

describe 'ProjectPollerHelper' do
  let(:project) { build(:jenkins_project) }
  let(:handler) { double(:handler) }
  let(:connection) { double(:connection, get: request) }
  let(:request) { double(:request, callback: nil, errback: nil) }
  let(:workload) { double(:workload, complete?: nil, unfinished_job_descriptions: {}) }

  let(:ci_strategy) { double(:polling_strategy, create_workload: workload) }
  let(:polling_strategy_factory) { double(:polling_strategy_factory, build_ci_strategy: ci_strategy) }

  before do
    allow(Project).to receive_message_chain(:updateable, :find_each).and_yield(project)
    allow(PollerWorkload).to receive(:new).and_return(workload)
    allow(EM::HttpRequest).to receive(:new).and_return(connection)
  end

  subject { ProjectPollerHelper.new(polling_strategy_factory) }

  describe '#poll_projects' do
    let(:updateable_projects) { double(:updateable_projects) }

    xcontext 'when there are no projects to update' do

    end

    context 'when there are projects to update' do

      let(:project1) { build(:project, name: 'project 1') }
      let(:project2) { build(:project, name: 'project 2') }
      let(:job_description) { {feed_url: 'https://feed/url'} }

      before do
        allow(workload).to receive(:unfinished_job_descriptions).and_return(job_description)
        allow(ci_strategy).to receive(:create_handler).and_return(handler)

        allow(Project).to receive(:updateable).and_return(updateable_projects)
        allow(updateable_projects).to receive(:find_each).and_yield(project1)
      end

      it 'should fetch status for each updateable project' do
        allow(updateable_projects).to receive(:find_each).and_yield(project1).and_yield(project2)
        expect(ci_strategy).to receive(:fetch_status).with(project1, 'https://feed/url')
        expect(ci_strategy).to receive(:fetch_status).with(project2, 'https://feed/url')

        subject.poll_projects
      end

      context 'when polling a project succeeds' do
        let(:workload) { double(:workload, complete?: true, unfinished_job_descriptions: {}) }

        before do
          allow(ci_strategy).to receive(:fetch_status).and_yield(PollState::SUCCEEDED, 'response body')
          allow(workload).to receive(:store).with(job_description.keys.first, 'response body')
          allow(handler).to receive(:workload_complete).with(workload)
        end

        it 'should notify the handler when all jobs in the workload are complete' do
          allow(workload).to receive(:unfinished_job_descriptions).and_return(
              {job_1: 'https://job/1', job_2: 'https://job/2'}
          )

          transcript = []
          allow(workload).to receive(:store).with(:job_1, 'response body') { transcript << 'store job 1' }
          allow(workload).to receive(:store).with(:job_2, 'response body') { transcript << 'store job 2' }
          allow(workload).to receive(:complete?) { transcript.count == 2 }
          allow(handler).to receive(:workload_complete).with(workload) { transcript << 'workload complete' }

          subject.poll_projects

          expect(transcript).to eq(['store job 1', 'store job 2', 'workload complete'])
        end

        it 'should remove the workload when complete' do
          subject.poll_projects

          expect(subject.instance_variable_get(:@workloads)).to be_empty
        end

        it 'should call the completion callback' do
          callback_called = false
          subject.poll_projects do
            callback_called = true
          end

          expect(callback_called).to be_truthy
        end
      end

      context 'when polling the project fails' do
        before do
          allow(ci_strategy).to receive(:fetch_status).and_yield(PollState::FAILED, 'it broke')
          allow(handler).to receive(:workload_failed).with('it broke')
        end

        it 'should not notify the handler that the workload failed' do
          expect(handler).to_not receive(:workload_complete)
          expect(handler).to receive(:workload_failed).with('it broke')

          subject.poll_projects
        end

        it 'should remove the workload' do
          subject.poll_projects

          expect(subject.instance_variable_get(:@workloads).values).to be_empty
        end

        it 'should call the completion callback' do
          callback_called = false
          subject.poll_projects do
            callback_called = true
          end

          expect(callback_called).to be_truthy
        end
      end
    end
  end

  xdescribe '#poll_tracker' do
    before do
      allow(Project).to receive(:tracker_updateable).and_return(double.as_null_object)
    end

    it 'should get the tracker updateable projects' do
      expect(Project).to receive(:tracker_updateable)
      subject.poll_tracker
    end

    context 'when there are jobs to complete' do
      let(:project) { double(:jenkins_project, tracker_project_url: double, tracker_auth_token: double) }
      let(:updateable_projects) { double(:updateable_projects) }

      before do
        allow(updateable_projects).to receive(:find_each).and_yield(project)
        allow(Project).to receive(:tracker_updateable).and_return(updateable_projects)
        allow(ProjectTrackerWorkloadHandler).to receive(:new).and_return(handler)
        allow(workload).to receive(:unfinished_job_descriptions).and_return({tracker_project_url: project.tracker_project_url})
        allow(workload).to receive(:add_job)
        allow(project).to receive(:tracker_current_iteration_url)
        allow(project).to receive(:tracker_iterations_url)
      end

      it 'should fetch the tracker url' do
        expect(connection).to receive(:get)
        subject.poll_tracker
      end

      context 'when the tracker project has an invalid URL' do
        before do
          allow(EM::HttpRequest).to receive(:new).and_raise(Addressable::URI::InvalidURIError.new)
        end

        it 'does not keep the related workload' do
          allow(ProjectTrackerWorkloadHandler).to receive(:new).and_return(double(:handler))

          subject.poll_tracker

          expect(subject.instance_variable_get(:@workloads)).to eq({})
        end
      end
    end
  end
end