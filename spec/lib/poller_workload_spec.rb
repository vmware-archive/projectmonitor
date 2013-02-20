require 'spec_helper'

describe PollerWorkload do

  let(:project) { double(:project) }
  let(:handler) { double(:handler, workload_created: nil, workload_complete: nil) }
  let(:workload) { PollerWorkload.new(handler) }

  subject { workload }

  before do
    project.stub(:handler) { handler }
    ProjectWorkloadHandler.stub(:new).and_return(handler)
  end

  it 'should tell the handler that the workload has been created' do
    handler.should_receive(:workload_created).with(workload)
    subject
  end

  its(:incomplete_jobs) { should be_empty }
  its(:complete?) { should be_true }
  its(:unfinished_job_descriptions) { should be_empty }

  context 'with a project' do
    let(:project) { double(:project, feed_url: 'http://www.example.com', build_status_url: nil).as_null_object }

    before do
      workload.add_job(:feed_url, project.feed_url)
      workload.add_job(:build_status_url, project.build_status_url)
    end

    its(:incomplete_jobs) { should =~ [:feed_url] }
    its(:unfinished_job_descriptions) { should == {feed_url: project.feed_url }}

    it 'should allow storing of content with a key' do
      workload.store(:feed_url, 'Blue Chips')
    end

    context 'when the feed_url bundle has been retrieved' do
      before do
        workload.store(:feed_url, 'Shazam')
      end

      its(:complete?) { should be_true }
      its(:unfinished_job_descriptions) { should == {} }

      it 'returns the stored content' do
        subject.recall(:feed_url).should == 'Shazam'
      end

    end

  end
end
