require_relative '../../app/models/volatility_calculator'

describe VolatilityCalculator do
  subject { VolatilityCalculator.new }
  describe 'calculating volatility' do
    context 'when project has this historical velocity' do
      it 'should return this volatility' do
        expect(subject.calculate_volatility([ 0,0,4,0,0,7,4,15,0,0 ])).to eq(163)
      end
    end

    context 'when project has no velocity' do
      it 'should return zero volatility' do
        expect(subject.calculate_volatility([ 0,0,0,0,0,0,0,0,0,0 ])).to eq(0)
      end
    end

    context 'when project has no historical velocity' do
      it 'should return correct volatility' do
        expect(subject.calculate_volatility([])).to eq(0)
      end
    end
  end
end