require 'spec_helper'

describe Volatility, :type => :model do
  describe ".calculate" do
    subject { Volatility.calculate(last_ten_velocities) }

    context "with simple velocity" do
      let(:last_ten_velocities) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }
      it { is_expected.to eq 55 }
    end

    context "with historical velocity" do
      let(:last_ten_velocities) { [0, 0, 4, 0, 0, 7, 4, 15, 0, 0] }
      it { is_expected.to eq 163 }
    end

    context "with zero velocity" do
      let(:last_ten_velocities) { [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
      it { is_expected.to eq 0 }
    end

    context "with no velocity object" do
      let(:last_ten_velocities) { [] }
      it { is_expected.to eq 0 }
    end
  end
end
