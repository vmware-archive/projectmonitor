require 'spec_helper'

describe PollerWorkload do

  let(:workload) { PollerWorkload.new }

  subject { workload }

  describe '#incomplete_jobs' do
    subject { workload.incomplete_jobs }
    it { is_expected.to be_empty }
  end

  describe '#complete?' do
    subject { workload.complete? }
    it { is_expected.to be true }
  end

  describe '#unfinished_job_descriptions' do
    subject { workload.unfinished_job_descriptions }
    it { is_expected.to be_empty }
  end

  describe 'adding jobs' do
    let(:feed_url) { 'http://www.example.com' }
    let(:build_status_url) { nil }

    before do
      workload.add_job(:feed_url, feed_url)
      workload.add_job(:build_status_url, build_status_url)
    end

    describe '#incomplete_jobs' do
      subject { workload.incomplete_jobs }
      it { is_expected.to match_array([:feed_url]) }
    end

    describe '#unfinished_job_descriptions' do
      subject { workload.unfinished_job_descriptions }
      it { is_expected.to eq({feed_url: feed_url })}
    end

    it 'should allow storing of content with a key' do
      workload.store(:feed_url, 'Blue Chips')
    end

    context 'when the feed_url bundle has been retrieved' do
      before do
        workload.store(:feed_url, 'Shazam')
      end

      describe '#complete?' do
        subject { workload.complete? }
        it { is_expected.to be true }
      end

      describe '#unfinished_job_descriptions' do
        subject { workload.unfinished_job_descriptions }
        it { is_expected.to eq({}) }
      end

      it 'returns the stored content' do
        expect(subject.recall(:feed_url)).to eq('Shazam')
      end

    end

  end
end
