require 'spec_helper'

describe ProjectPoller do
  let(:project) { build(:project, name: 'project 1') }
  let(:jobs) { {job_1: 'https://url/1', job_2: 'https://url/2'} }
  let(:ci_strategy) { double(:polling_strategy) }
  let(:completion_block) { Proc.new { nil } }
  let(:handler) { double(:handler) }

  subject { ProjectPoller.new }

  describe '#poll_project' do
    context 'when there are projects to update' do
      before do
        allow(ci_strategy).to receive(:create_handler).and_return(handler)
      end

      it 'should fetch status for each job description in the workload' do
        expect(ci_strategy).to receive(:fetch_status).with(project, 'https://url/1')
        expect(ci_strategy).to receive(:fetch_status).with(project, 'https://url/2')

        subject.poll_project(project, ci_strategy, jobs, &completion_block)
      end

      it 'should call the completion callback immediately if there are no jobs' do
        jobs = {}

        callback_called = false
        subject.poll_project(project, ci_strategy, jobs) do |success_flag, response|
          callback_called = true
          expect(success_flag).to eq(false)
          expect(response).to eq('no jobs found')
        end

        expect(callback_called).to be_truthy
      end

      context 'when polling a project succeeds' do
        before do
          allow(ci_strategy).to receive(:fetch_status).and_yield(PollState::SUCCEEDED, 'response body', 200)
        end

        it 'should call the completion callback' do
          callback_called = false
          subject.poll_project(project, ci_strategy, jobs) do |success_flag, response|
            callback_called = true
            expect(success_flag).to eq(true)
            expect(response).to eq({job_1: 'response body', job_2: 'response body'})
          end

          expect(callback_called).to be_truthy
        end

        context 'when one of the jobs could not determine the build status' do
          before do
            allow(ci_strategy).to receive(:fetch_status).and_yield(PollState::SUCCEEDED, 'project not found', 404)
          end

          it 'should call the completion callback' do
            callback_called = false
            subject.poll_project(project, ci_strategy, jobs) do |success_flag, response|
              callback_called = true
              expect(success_flag).to eq(false)
              expect(response).to eq('project not found')
            end

            expect(callback_called).to be_truthy
          end

          it 'should abort the polling and not fetch further jobs' do
            call_count = 0
            subject.poll_project(project, ci_strategy, jobs) do
              call_count += 1
            end

            expect(call_count).to eq(1)
          end
        end
      end

      context 'when polling the project fails' do
        before do
          allow(ci_strategy).to receive(:fetch_status).and_yield(PollState::FAILED, 'it broke', -1)
          allow(handler).to receive(:workload_failed).with('it broke')
        end

        it 'should call the completion callback' do
          callback_called = false

          subject.poll_project(project, ci_strategy, jobs) do |success_flag, response|
            callback_called = true
            expect(success_flag).to be_falsey
            expect(response).to eq 'it broke'
          end

          expect(callback_called).to be_truthy
        end
      end
    end
  end
end