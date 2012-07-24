require 'spec_helper'

describe PayloadProcessor do
  describe "#initialize" do
    let(:project) { double(:project) }
    let(:payload) { double(:payload) }
    subject { PayloadProcessor.new(project, payload) }
    its(:project) { should == project }
    its(:payload) { should == payload }
  end
end
