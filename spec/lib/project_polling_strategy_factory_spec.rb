require 'spec_helper'

describe ProjectPollingStrategyFactory do

  subject { ProjectPollingStrategyFactory.new }

  describe '#build_ci_strategy' do
    it 'should return a concourse strategy for concourse projects' do
      strategy = subject.build_ci_strategy(ConcourseProject.new)
      expect(strategy.class).to eq(ConcourseProjectStrategy)
    end

    it 'should return a ci strategy for non-concourse projects' do
      strategy = subject.build_ci_strategy(JenkinsProject.new)
      expect(strategy.class).to eq(CIPollingStrategy)
    end
  end
end