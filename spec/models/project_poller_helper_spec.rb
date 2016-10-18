require 'spec_helper'

describe ProjectPollerHelper do

  let(:tracker_strategy) { double(:tracker_strategy) }
  let(:ci_polling_strategy) { double(:ci_polling_strategy) }
  let(:handler) { double(:handler) }
  let(:project_poller) { double(:project_poller) }
  let(:polling_strategy_factory) { double(:polling_strategy_factory, build_ci_strategy: ci_polling_strategy) }
  let(:completion_block) { Proc.new { nil } }
  let(:workload) { double(:workload, complete?: nil, job_urls: {job_1: 'some/url'}) }

  subject { ProjectPollerHelper.new(polling_strategy_factory, project_poller) }

  before do
    allow(tracker_strategy).to receive(:create_handler).and_return(handler)
    allow(ci_polling_strategy).to receive(:create_handler).and_return(handler)
  end

  describe '#poll_projects' do
    context 'when there are projects to update' do
      let(:project) { build(:jenkins_project) }
      let(:updateable_projects) { double(:projects) }

      before do
        allow(updateable_projects).to receive(:find_each).and_yield(project)
        allow(Project).to receive(:updateable).and_return(updateable_projects)
        allow(polling_strategy_factory).to receive(:build_ci_strategy).with(project).and_return(ci_polling_strategy)
        allow(ci_polling_strategy).to receive(:create_workload).with(project).and_return(workload)
      end

      it 'should fetch status for each project' do
        expect(project_poller).to receive(:poll_project).with(project, ci_polling_strategy, workload.job_urls)
        subject.poll_projects(&completion_block)
      end
    end
  end

  describe '#poll_tracker' do
    context 'when there are projects to update' do
      let(:project) { build(:project_with_tracker_integration) }
      let(:projects_with_tracker) { double(:projects) }
      let(:tracker_strategy) { double(:tracker_strategy) }
      let(:completion_block) { Proc.new { nil } }

      before do
        allow(projects_with_tracker).to receive(:find_each).and_yield(project)
        allow(Project).to receive(:tracker_updateable).and_return(projects_with_tracker)
        allow(polling_strategy_factory).to receive(:build_tracker_strategy).and_return(tracker_strategy)
        allow(tracker_strategy).to receive(:create_workload).with(project).and_return(workload)
        allow(handler).to receive(:workload_complete)
        allow(project_poller).to receive(:poll_project).with(project, tracker_strategy, workload.job_urls).and_yield(true, 'success')
      end

      it 'should fetch status for each project with tracker' do
        expect(project_poller).to receive(:poll_project).with(project, tracker_strategy, workload.job_urls)
        subject.poll_tracker(&completion_block)
      end

      it 'should remove the workload once complete' do
        subject.poll_tracker(&completion_block)
        expect(subject.instance_variable_get(:@workloads).count).to eq 0
      end

      context 'and the update succeeds' do
        it 'should tell the handler the workload is complete' do
          expect(handler).to receive(:workload_complete).with('success')
          subject.poll_tracker(&completion_block)
        end
      end

      context 'and the update fails' do
        before do
          allow(project_poller).to receive(:poll_project).with(project, tracker_strategy, workload.job_urls).and_yield(false, 'failed')
        end

        it 'should tell the handler the workload failed' do
          expect(handler).to receive(:workload_failed).with('failed')
          subject.poll_tracker(&completion_block)
        end
      end
    end
  end
end


