require 'spec_helper'

describe Payload do
  describe "#initialize" do
    subject { Payload.new }

    describe '#parsed_successfully' do
      subject { super().parsed_successfully }
      it { is_expected.to eq(true) }
    end

    describe '#build_parsed_successfully' do
      subject { super().build_parsed_successfully }
      it { is_expected.to eq(true) }
    end
  end
end
