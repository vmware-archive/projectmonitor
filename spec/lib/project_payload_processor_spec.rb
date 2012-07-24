require 'spec_helper'

describe ProjectPayloadProcessor do
  describe "#initialize" do
    let(:project) { double(:project) }
    let(:payload) { double(:payload) }
    subject { ProjectPayloadProcessor.new(project, payload) }
    its(:project) { should == project }
    its(:payload) { should == payload }
  end
end
