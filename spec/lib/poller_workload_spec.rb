require 'spec_helper'

describe PollerWorkload do

  let(:project) { double(:project) }
  let(:handler) { double(:handler, workload_created: nil, workload_complete: nil) }
  let(:workload) { PollerWorkload.new(handler) }

  subject { workload }

  before do
    allow(project).to receive(:handler) { handler }
    allow(ProjectWorkloadHandler).to receive(:new).and_return(handler)
  end

  it 'should tell the handler that the workload has been created' do
    subject
    expect(handler).to have_received(:workload_created).with(workload)
  end

  describe '#incomplete_jobs' do
    subject { super().incomplete_jobs }
    it { is_expected.to be_empty }
  end

  describe '#complete?' do
    subject { super().complete? }
    it { is_expected.to be true }
  end

  describe '#unfinished_job_descriptions' do
    subject { super().unfinished_job_descriptions }
    it { is_expected.to be_empty }
  end

  context 'with a project' do
    let(:project) { double(:project, feed_url: 'http://www.example.com', build_status_url: nil).as_null_object }

    before do
      workload.add_job(:feed_url, project.feed_url)
      workload.add_job(:build_status_url, project.build_status_url)
    end

    describe '#incomplete_jobs' do
      subject { super().incomplete_jobs }
      it { is_expected.to match_array([:feed_url]) }
    end

    describe '#unfinished_job_descriptions' do
      subject { super().unfinished_job_descriptions }
      it { is_expected.to eq({feed_url: project.feed_url })}
    end

    it 'should allow storing of content with a key' do
      workload.store(:feed_url, 'Blue Chips')
    end

    context 'when the feed_url bundle has been retrieved' do
      before do
        workload.store(:feed_url, 'Shazam')
      end

      describe '#complete?' do
        subject { super().complete? }
        it { is_expected.to be true }
      end

      describe '#unfinished_job_descriptions' do
        subject { super().unfinished_job_descriptions }
        it { is_expected.to eq({}) }
      end

      it 'returns the stored content' do
        expect(subject.recall(:feed_url)).to eq('Shazam')
      end

    end

  end
end
