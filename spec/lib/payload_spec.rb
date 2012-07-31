require 'spec_helper'

describe Payload do
  describe "#initialize" do
    subject { Payload.new }
    its(:processable) { should == true }
    its(:build_processable) { should == true }
  end
end
