require 'spec_helper'

describe 'ProjectPollerHelper' do
  let(:project) { build(:jenkins_project) }
  let(:handler) { double(:handler) }
  let(:connection) { double(:connection, get: request) }
  let(:request) { double(:request, callback: nil, errback: nil) }
  let(:workload) { double(:workload, complete?: nil, unfinished_job_descriptions: {}) }

  before do
    allow(Project).to receive_message_chain(:updateable, :find_each).and_yield(project)
    allow(PollerWorkload).to receive(:new).and_return(workload)
    allow(EM::HttpRequest).to receive(:new).and_return(connection)
  end

  subject { ProjectPollerHelper.new }

  describe '#poll_projects' do
    before do
      allow(workload).to receive(:add_job).with(:feed_url, 'http://www.example.com/job/project/rssAll')
      allow(workload).to receive(:add_job).with(:build_status_url, 'http://www.example.com/cc.xml')
      allow(workload).to receive(:unfinished_job_descriptions).and_return({feed_url: project.feed_url})
      allow(ProjectWorkloadHandler).to receive(:new).and_return(handler)
    end

    context 'and there is an updateable project' do
      it 'should create a project workload' do
        expect {
          subject.poll_projects
        }.to change { subject.instance_variable_get(:@workloads).count }.by (1)
      end

      it 'should get the updateable projects' do
        expect(Project).to receive(:updateable)
        subject.poll_projects
      end

      context 'when there are jobs to complete' do
        before do
          allow(workload).to receive(:unfinished_job_descriptions).and_return({feed_url: project.feed_url})
        end

        it 'should register for a response' do
          expect(request).to receive(:callback)
          subject.poll_projects
        end

        it 'should register for an error' do
          expect(request).to receive(:errback)
          subject.poll_projects
        end

        context 'when the project has an invalid URL' do
          before do
            allow(EM::HttpRequest).to receive(:new).and_raise(Addressable::URI::InvalidURIError.new)
          end

          it 'does not keep the related workload' do
            allow(ProjectWorkloadHandler).to receive(:new).and_return(double(:handler))

            subject.poll_projects

            expect(subject.instance_variable_get(:@workloads)).to eq({})
          end
        end

        context 'when a response is received' do
          let(:client) { double(:client, response: double) }

          before do
            allow(request).to receive(:callback).and_yield(client)
            allow(workload).to receive(:store)
          end

          it 'should store the payload in the workload' do
            expect(workload).to receive(:store).with(:feed_url, client.response)
            subject.poll_projects
          end

          it 'should determine if the workload is complete' do
            expect(workload).to receive(:complete?)
            subject.poll_projects
          end

          context 'and the workload is complete' do
            before do
              allow(workload).to receive(:complete?).and_return(true)
              allow(workload).to receive(:recall)
              allow(handler).to receive(:workload_complete)
            end

            it 'should remove the workload' do
              subject.poll_projects

              expect(subject.instance_variable_get(:@workloads)).to eq({})
            end
          end
        end
      end

      context 'when an error occurs' do
        let(:client) { double(:client, error: double) }

        before do
          allow(request).to receive(:errback).and_yield(client)
          allow(handler).to receive(:workload_failed).with(client.error)
        end

        it 'should mark the project as failed' do
          expect(handler).to receive(:workload_failed).with(client.error)
          subject.poll_projects
        end

        it 'should remove the workload' do
          subject.poll_projects

          expect(subject.instance_variable_get(:@workloads)).to eq({})
        end
      end
    end
  end

  describe '#poll_tracker' do
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