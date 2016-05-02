require 'spec_helper'

describe ProjectPoller do

  let(:poller) { ProjectPoller.new }

  describe '#run' do
    before do
      allow(EM).to receive(:run).and_yield
      allow(EM).to receive(:add_periodic_timer)
    end

    it 'should call EM::run' do
      expect(EM).to receive(:run)
      poller.run
    end

    it 'should add a periodic timer to poll projects' do
      expect(EM).to receive(:add_periodic_timer)
      poller.run
    end

    context 'the ci poller periodic timer has elapsed' do
      before do
        allow(EM).to receive(:add_periodic_timer).and_yield
        allow(Project).to receive(:updateable).and_return(double.as_null_object)
      end

      it 'should get the updateable projects' do
        expect(Project).to receive(:updateable)
        poller.run
      end

      context 'and there is an updateable project' do
        let(:project) { build(:jenkins_project) }
        let(:connection) { double(:connection, get: request) }
        let(:request) { double(:request, callback: nil, errback: nil) }
        let(:workload) { double(:workload, complete?: nil, unfinished_job_descriptions: {}) }

        before do
          allow(Project).to receive_message_chain(:updateable, :find_each).and_yield(project)
          allow(PollerWorkload).to receive(:new).and_return(workload)
          allow(EM::HttpRequest).to receive(:new).and_return(connection)
        end

        it 'should create a project workload' do
          handler = double
          allow(ProjectWorkloadHandler).to receive(:new).and_return(handler)
          expect(PollerWorkload).to receive(:new).with(handler)
          poller.run
        end

        context 'when there are jobs to complete' do
          before do
            allow(workload).to receive(:unfinished_job_descriptions).and_return({feed_url: project.feed_url})
          end

          it 'should be initialized with the feed url and timeouts' do
            expect(EM::HttpRequest).to receive(:new).with('http://www.example.com/job/project/rssAll', connect_timeout: 60, inactivity_timeout: 30)
            poller.run
          end

          it 'should call get and follow up to 10 redirects' do
            expect(connection).to receive(:get).with(redirects: 10)
            poller.run
          end

          it 'should register for a response' do
            expect(request).to receive(:callback)
            poller.run
          end

          it 'should register for an error' do
            expect(request).to receive(:errback)
            poller.run
          end

          context 'and authentication is required' do
            let(:username) { double }
            before do
              allow(project).to receive(:auth_username).and_return(username)
            end

            it 'should set the authorization header' do
              expect(connection).to receive(:get).with(redirects: 10, head: {'authorization' => [username, nil]})
              poller.run
            end
          end

          context 'and the project has accept_mime_types' do
            let(:mime_type) { "application/json" }
            before do
              allow(project).to receive(:accept_mime_types).and_return(mime_type)
            end

            it 'should set the authorization header' do
              expect(connection).to receive(:get).with(redirects: 10, head: {'Accept' => mime_type})
              poller.run
            end
          end

          context 'when the project has an invalid URL' do
            before do
              allow(EM::HttpRequest).to receive(:new).and_raise(Addressable::URI::InvalidURIError.new)
            end

            it 'does not make a new workload' do
              handler = double
              allow(ProjectWorkloadHandler).to receive(:new).and_return(handler)
              expect(PollerWorkload).to receive(:new).with(handler)
              expect {
                poller.run
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
              poller.run
            end

            it 'should determine if the workload is complete' do
              expect(workload).to receive(:complete?)
              poller.run
            end

            context 'and the workload is complete' do
              before do
                allow(workload).to receive(:complete?).and_return(true)
                allow(workload).to receive(:recall)
              end

              it 'should remove the workload' do
                expect(poller).to receive(:remove_workload)
                poller.run
              end
            end
          end

          context 'when an error occurs' do
            let(:client) { double(:client, error: double) }

            before do
              allow(request).to receive(:errback).and_yield(client)
              allow(workload).to receive(:failed)
            end

            it 'should mark the project as failed' do
              expect(workload).to receive(:failed)
              poller.run
            end

            it 'should remove the workload' do
              expect(poller).to receive(:remove_workload)
              poller.run
            end
          end
        end
      end
    end

    context 'the tracker poller periodic timer has elapsed' do
      let(:connection) { double(:connection, get: request) }
      let(:request) { double(:request, callback: nil, errback: nil) }
      let(:workload) { double(:workload, complete?: nil, unfinished_job_descriptions: {}) }

      before do
        allow(poller).to receive(:poll_projects) # XXX: Because rspec doesn't support conditional yields
        allow(EM).to receive(:add_periodic_timer).and_yield.and_yield
        allow(EM::HttpRequest).to receive(:new).and_return(connection)
        allow(Project).to receive(:tracker_updateable).and_return(double.as_null_object)
        allow(ProjectTrackerWorkloadHandler).to receive(:new).and_return(double.as_null_object)
        allow(PollerWorkload).to receive(:new).and_return(workload)
      end

      it 'should get the tracker updateable projects' do
        expect(Project).to receive(:tracker_updateable)
        poller.run
      end

      context 'and there are tracker updateable projects' do
        let(:project) { double(:jenkins_project, tracker_project_url: double, tracker_auth_token: double) }

        before do
          allow(Project).to receive_message_chain(:tracker_updateable, :find_each).and_yield(project)
        end

        it 'should create a workload' do
          expect(PollerWorkload).to receive(:new)
          poller.run
        end

        context 'when there are jobs to complete' do
          before do
            allow(workload).to receive(:unfinished_job_descriptions).and_return({tracker_project_url: project.tracker_project_url})
          end

          it 'should set the tracker header' do
            expect(connection).to receive(:get).with(redirects: 10, head: {'X-TrackerToken' => project.tracker_auth_token})
            poller.run
          end

          it 'should be initialized with the tracker_url and timeouts' do
            expect(EM::HttpRequest).to receive(:new).with("http://#{project.tracker_project_url}", connect_timeout: 60, inactivity_timeout: 30)
            poller.run
          end
        end
      end
    end
  end

  describe '#stop' do
    it 'should call EM.stop_event_loop' do
      expect(EM).to receive(:stop_event_loop)
      poller.stop
    end
  end

end
