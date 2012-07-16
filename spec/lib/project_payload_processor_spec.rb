require 'spec_helper'

describe ProjectPayloadProcessor do
  describe "#process" do
    let(:project) { double(Project, processor: processor_class)}
    let(:processor_class) { double(Class, new: processor_instance)}
    let(:processor_instance) { double(TravisPayloadProcessor, process: nil) }
    let(:payload) { "<foo></foo>"}

    it "instantiates a project specific payload_processor" do
      processor_class.should_receive :new
      processor_instance.should_receive :process

      ProjectPayloadProcessor.new(project,payload).perform
    end
  end
end
