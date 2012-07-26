require 'spec_helper'

describe Payload do
  describe "#initialize" do
    let(:project) { double(:project) }
    subject { Payload.new(project) }
    its(:project) { should == project }
    its(:processable) { should == true }
    its(:build_processable) { should == true }
  end

  describe "#content" do
    let(:content) { double(:content) }
    subject { Payload.new(double).content(content) }
    its(:status_content) { should == content }
    its(:build_status_content) { should == content }
  end
end
