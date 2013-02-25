require 'spec_helper'

describe ProjectPoller do

  let(:poller) { ProjectPoller.new }

  describe '#run' do
    before do
      EM.stub(:run).and_yield
      EM.stub(:add_periodic_timer)
    end

    after do
      poller.run
    end

    it 'should call EM::run' do
      EM.should_receive(:run)
    end

    it 'should add a periodic timer to poll projects' do
      EM.should_receive(:add_periodic_timer)
    end

    context 'the ci poller periodic timer has elapsed' do
      before do
        EM.stub(:add_periodic_timer).and_yield
        Project.stub(:updateable).and_return(double.as_null_object)
      end

      it 'should get the updateable projects' do
        Project.should_receive(:updateable)
      end

      context 'and there is an updateable project' do
        let(:project) { FactoryGirl.build(:jenkins_project) }
        let(:connection) { double(:connection, get: request) }
        let(:request) { double(:request, callback: nil, errback: nil) }
        let(:workload) { double(:workload, complete?: nil, unfinished_job_descriptions: {}) }

        before do
          Project.stub_chain(:updateable, :find_each).and_yield(project)
          PollerWorkload.stub(:new).and_return(workload)
          EM::HttpRequest.stub(:new).and_return(connection)
        end

        it 'should create a project workload' do
          handler = double
          project.stub(:handler) { handler }
          PollerWorkload.should_receive(:new).with(handler)
        end

        context 'when there are jobs to complete' do
          before do
            workload.stub(:unfinished_job_descriptions).and_return({feed_url: project.feed_url})
          end

          it 'should be initialized with the feed url and timeouts' do
            EM::HttpRequest.should_receive(:new).with('http://www.example.com/job/project/rssAll', connect_timeout: 60, inactivity_timeout: 60)
          end

          it 'should call get and follow up to 10 redirects' do
            connection.should_receive(:get).with(redirects: 10)
          end

          it 'should register for a response' do
            request.should_receive(:callback)
          end

          it 'should register for an error' do
            request.should_receive(:errback)
          end

          context 'and authentication is required' do
            let(:username) { double }
            before do
              project.stub(:auth_username).and_return(username)
            end

            it 'should set the authorization header' do
              connection.should_receive(:get).with(redirects: 10, head: {'authorization' => [username, nil]})
            end
          end

          context 'when a response is received' do
            let(:client) { double(:client, response: double) }

            before do
              request.stub(:callback).and_yield(client)
              workload.stub(:store)
            end

            it 'should store the payload in the workload' do
              workload.should_receive(:store).with(:feed_url, client.response)
            end

            it 'should determine if the workload is complete' do
              workload.should_receive(:complete?)
            end

            context 'and the workload is complete' do
              before do
                workload.stub(:complete?).and_return(true)
                workload.stub(:recall)
              end

              it 'should remove the workload' do
                poller.should_receive(:remove_workload)
              end
            end
          end

          context 'when an error occurs' do
            let(:client) { double(:client, error: double) }

            before do
              request.stub(:errback).and_yield(client)
              workload.stub(:failed)
            end

            it 'should mark the project as failed' do
              workload.should_receive(:failed)
            end

            it 'should remove the workload' do
              poller.should_receive(:remove_workload)
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
        poller.stub(:poll_projects) # XXX: Because rspec doesn't support conditional yields
        EM.stub(:add_periodic_timer).and_yield.and_yield
        EM::HttpRequest.stub(:new).and_return(connection)
        Project.stub(:tracker_updateable).and_return(double.as_null_object)
        ProjectTrackerWorkloadHandler.stub(:new).and_return(double.as_null_object)
        PollerWorkload.stub(:new).and_return(workload)
      end

      it 'should get the tracker updateable projects' do
        Project.should_receive(:tracker_updateable)
      end

      context 'and there are tracker updateable projects' do
        let(:project) { double(:jenkins_project, tracker_project_url: double, tracker_auth_token: double) }

        before do
          Project.stub_chain(:tracker_updateable, :find_each).and_yield(project)
        end

        it 'should create a workload' do
          PollerWorkload.should_receive(:new)
        end

        context 'when there are jobs to complete' do
          before do
            workload.stub(:unfinished_job_descriptions).and_return({tracker_project_url: project.tracker_project_url})
          end

          it 'should set the tracker header' do
            connection.should_receive(:get).with(redirects: 10, head: {'X-TrackerToken' => project.tracker_auth_token})
          end

          it 'should be initialized with the tracker_url and timeouts' do
            EM::HttpRequest.should_receive(:new).with(project.tracker_project_url, connect_timeout: 60, inactivity_timeout: 60)
          end
        end
      end
    end
  end

  describe '#stop' do
    it 'should call EM.stop_event_loop' do
      EM.should_receive(:stop_event_loop)
      poller.stop
    end
  end

end
