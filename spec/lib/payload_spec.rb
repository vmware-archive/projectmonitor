require 'spec_helper'

describe Payload do
  describe "#initialize" do
    let(:project) { double(:project) }
    subject { Payload.new(project) }
    its(:project) { should == project }
    its(:processable) { should == true }
    its(:build_processable) { should == true }
  end
end
