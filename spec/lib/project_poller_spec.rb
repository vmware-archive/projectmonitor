require 'spec_helper'

describe ProjectPoller do
  let(:project) { build(:project, name: 'project 1') }
  let(:workload) { double(:workload, complete?: nil) }
  let(:ci_strategy) { double(:polling_strategy) }
  let(:completion_block) { Proc.new { nil } }
  let(:handler) { double(:handler) }

  subject { ProjectPoller.new }

  describe '#poll_project' do
    context 'when there are projects to update' do
      let(:job_description) { {url_1: 'https://url/1', url_2: 'https://url/2'} }

      before do
        allow(workload).to receive(:unfinished_job_descriptions).and_return(job_description)
        allow(ci_strategy).to receive(:create_handler).and_return(handler)
      end

      it 'should fetch status for each job description in the workload' do
        expect(ci_strategy).to receive(:fetch_status).with(project, 'https://url/1')
        expect(ci_strategy).to receive(:fetch_status).with(project, 'https://url/2')

        subject.poll_project(project, ci_strategy, workload, &completion_block)
      end

      context 'when polling a project succeeds' do
        let(:workload) { double(:workload, complete?: true, unfinished_job_descriptions: {}) }

        before do
          allow(ci_strategy).to receive(:fetch_status).and_yield(PollState::SUCCEEDED, 'response body', 200)
          allow(workload).to receive(:store)
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

          subject.poll_project(project, ci_strategy, workload, &completion_block)

          expect(transcript).to eq(['store job 1', 'store job 2', 'workload complete'])
        end

        it 'should call the completion callback' do
          callback_called = false
          subject.poll_project(project, ci_strategy, workload) do
            callback_called = true
          end

          expect(callback_called).to be_truthy
        end

        context 'when one of the jobs could not determine the build status' do
          before do
            allow(ci_strategy).to receive(:fetch_status).and_yield(PollState::SUCCEEDED, 'project not found', 404)
            allow(workload).to receive(:unfinished_job_descriptions).and_return({job_1: 'https://job/1'})
            allow(handler).to receive(:workload_failed).with('project not found')
          end

          it 'should notify the handler that the workload failed' do
            expect(handler).to receive(:workload_failed).with('project not found')
            subject.poll_project(project, ci_strategy, workload, &completion_block)
          end

          it 'should call the completion callback' do
            callback_called = false
            subject.poll_project(project, ci_strategy, workload) do
              callback_called = true
            end

            expect(callback_called).to be_truthy
          end
        end
      end

      context 'when polling the project fails' do
        before do
          allow(ci_strategy).to receive(:fetch_status).and_yield(PollState::FAILED, 'it broke', -1)
          allow(handler).to receive(:workload_failed).with('it broke')
        end

        it 'should notify the handler that the workload failed' do
          expect(handler).to_not receive(:workload_complete)
          expect(handler).to receive(:workload_failed).with('it broke')

          subject.poll_project(project, ci_strategy, workload, &completion_block)
        end

        it 'should call the completion callback' do
          callback_called = false
          subject.poll_project(project, ci_strategy, workload) do
            callback_called = true
          end

          expect(callback_called).to be_truthy
        end
      end
    end
  end
end