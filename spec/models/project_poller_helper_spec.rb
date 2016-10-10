require 'spec_helper'

describe 'ProjectPollerHelper' do

  subject { ProjectPollerHelper.new }

  describe '#poll_projects' do
    let(:project) { build(:jenkins_project) }
    let(:handler) { double(:handler) }

    before do
      allow(EM).to receive(:run).and_yield
      allow(EM).to receive(:add_periodic_timer)
    end

    context 'the ci poller periodic timer has elapsed' do
      before do
        allow(EM).to receive(:add_periodic_timer).and_yield
      end

      context 'and there is an updateable project' do
        let(:connection) { double(:connection, get: request) }
        let(:request) { double(:request, callback: nil, errback: nil) }
        let(:workload) { double(:workload, complete?: nil, unfinished_job_descriptions: {}) }

        before do
          allow(Project).to receive_message_chain(:updateable, :find_each).and_yield(project)
          allow(PollerWorkload).to receive(:new).and_return(workload)
          allow(EM::HttpRequest).to receive(:new).and_return(connection)
          allow(workload).to receive(:add_job).with(:feed_url, 'http://www.example.com/job/project/rssAll')
          allow(workload).to receive(:add_job).with(:build_status_url, 'http://www.example.com/cc.xml')
          allow(workload).to receive(:unfinished_job_descriptions).and_return({feed_url: project.feed_url})
          allow(ProjectWorkloadHandler).to receive(:new).and_return(handler)
          allow(handler).to receive(:workload_created).with(workload)
        end

        it 'should create a project workload' do
          handler = double
          allow(ProjectWorkloadHandler).to receive(:new).and_return(handler)
          allow(handler).to receive(:workload_created)
          expect(PollerWorkload).to receive(:new)
          subject.poll_projects
        end

        it 'should get the updateable projects' do
          expect(Project).to receive(:updateable)
          subject.poll_projects
        end

        context 'when there are jobs to complete' do
          before do
            allow(workload).to receive(:unfinished_job_descriptions).and_return({feed_url: project.feed_url})
          end

          it 'should be initialized with the feed url and timeouts' do
            expect(EM::HttpRequest).to receive(:new).with('http://www.example.com/job/project/rssAll', connect_timeout: 60, inactivity_timeout: 30)
            subject.poll_projects
          end

          it 'should call get and follow up to 10 redirects' do
            expect(connection).to receive(:get).with(redirects: 10)
            subject.poll_projects
          end

          it 'should register for a response' do
            expect(request).to receive(:callback)
            subject.poll_projects
          end

          it 'should register for an error' do
            expect(request).to receive(:errback)
            subject.poll_projects
          end

          context 'and authentication is required' do
            let(:username) { double }
            before do
              allow(project).to receive(:auth_username).and_return(username)
            end

            it 'should set the authorization header' do
              expect(connection).to receive(:get).with(redirects: 10, head: {'authorization' => [username, nil]})
              subject.poll_projects
            end
          end

          context 'and the project has accept_mime_types' do
            let(:mime_type) { "application/json" }
            before do
              allow(project).to receive(:accept_mime_types).and_return(mime_type)
            end

            it 'should set the authorization header' do
              expect(connection).to receive(:get).with(redirects: 10, head: {'Accept' => mime_type})
              subject.poll_projects
            end
          end

          context 'when the project has an invalid URL' do
            before do
              allow(EM::HttpRequest).to receive(:new).and_raise(Addressable::URI::InvalidURIError.new)
            end

            it 'does not make a new workload' do
              handler = double(:handler)
              allow(handler).to receive(:workload_created).with(workload)
              allow(ProjectWorkloadHandler).to receive(:new).and_return(handler)
              expect(PollerWorkload).to receive(:new)
              expect {
                subject.poll_projects
              }.to output(/ERROR/).to_stdout
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
                expect(subject).to receive(:remove_workload)
                subject.poll_projects
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
            expect(subject).to receive(:remove_workload)
            subject.poll_projects
          end
        end
      end
    end
  end

  describe '#poll_tracker' do
    let(:project) { build(:jenkins_project) }
    let(:handler) { double(:handler) }

    before do
      allow(EM).to receive(:run).and_yield
      allow(EM).to receive(:add_periodic_timer)
    end

    context 'the tracker poller periodic timer has elapsed' do
      let(:connection) { double(:connection, get: request) }
      let(:request) { double(:request, callback: nil, errback: nil) }
      let(:workload) { double(:workload, complete?: nil, unfinished_job_descriptions: {}) }

      before do
        allow(EM::HttpRequest).to receive(:new).and_return(connection)
        allow(Project).to receive(:tracker_updateable).and_return(double.as_null_object)
        allow(PollerWorkload).to receive(:new).and_return(workload)
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
          allow(handler).to receive(:workload_created)
          allow(workload).to receive(:unfinished_job_descriptions).and_return({tracker_project_url: project.tracker_project_url})
        end

        it 'should set the tracker header' do
          expect(connection).to receive(:get).with(redirects: 10, head: {'X-TrackerToken' => project.tracker_auth_token})
          subject.poll_tracker
        end

        it 'should be initialized with the tracker_url and timeouts' do
          expect(EM::HttpRequest).to receive(:new).with("http://#{project.tracker_project_url}", connect_timeout: 60, inactivity_timeout: 30)
          subject.poll_tracker
        end

        it 'should fetch the tracker url' do
          expect(connection).to receive(:get)
          subject.poll_tracker
        end
      end
    end
  end
end