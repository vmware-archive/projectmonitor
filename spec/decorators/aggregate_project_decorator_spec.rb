require 'spec_helper'

describe AggregateProjectDecorator do
  let(:aggregate_project_decorator) { AggregateProjectDecorator.new(aggregate_project) }
  let(:aggregate_project) { AggregateProject.new }

  subject { aggregate_project_decorator }

  describe "#css_id" do
    let(:aggregate_project) { AggregateProject.new(id: 123) }

    describe '#css_id' do
      subject { super().css_id }
      it { is_expected.to eq("aggregate_project_123") }
    end
  end

  context "the aggregate project has a failure status" do
    before { allow(aggregate_project).to receive(:state).and_return(Project::State.failure) }

    describe '#css_class' do
      subject { super().css_class }
      it { is_expected.to eq("project failure aggregate") }
    end

    describe '#status_in_words' do
      subject { super().status_in_words }
      it { is_expected.to eq("failure") }
    end
  end

  context "the aggregate project has a success status" do
    before { allow(aggregate_project).to receive(:state).and_return(Project::State.success) }

    describe '#css_class' do
      subject { super().css_class }
      it { is_expected.to eq("project success aggregate") }
    end

    describe '#status_in_words' do
      subject { super().status_in_words }
      it { is_expected.to eq("success") }
    end
  end

  context "the aggregate project has no statuses" do
    before { allow(aggregate_project).to receive(:state).and_return(Project::State.indeterminate) }

    describe '#css_class' do
      subject { super().css_class }
      it { is_expected.to eq("project indeterminate aggregate") }
    end

    describe '#status_in_words' do
      subject { super().status_in_words }
      it { is_expected.to eq("indeterminate") }
    end
  end

  context "the aggregate project is offline" do
    before { allow(aggregate_project).to receive(:state).and_return(Project::State.offline) }

    describe '#css_class' do
      subject { super().css_class }
      it { is_expected.to eq("project offline aggregate") }
    end

    describe '#status_in_words' do
      subject { super().status_in_words }
      it { is_expected.to eq("offline") }
    end
  end
end
