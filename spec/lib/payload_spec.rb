require 'spec_helper'

describe Payload do
  describe "#initialize" do
    subject { Payload.new }

    describe '#processable' do
      subject { super().processable }
      it { is_expected.to eq(true) }
    end

    describe '#build_processable' do
      subject { super().build_processable }
      it { is_expected.to eq(true) }
    end
  end

  describe '#build_branch_matches anything by default' do
    subject { super().build_branch_matches('anything')}
    it { is_expected.to eq(true) }
  end
end
