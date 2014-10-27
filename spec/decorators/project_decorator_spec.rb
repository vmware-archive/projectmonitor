require 'spec_helper'

describe ProjectDecorator do
  let(:project_decorator) { ProjectDecorator.new(project) }
  let(:project) { Project.new }

  subject { project_decorator }

  describe "#css_id" do
    context "when Project" do
      let(:project) { Project.new(id: 123) }

      describe '#css_id' do
        subject { super().css_id }
        it { is_expected.to eq("project_123") }
      end
    end
  end

  describe "#current_build_url" do
    describe '#current_build_url' do
      subject { super().current_build_url }
      it { is_expected.to be_nil }
    end
  end

  context "the project has a failure status" do
    before { project.stub(state: Project::State.failure) }

    describe '#css_class' do
      subject { super().css_class }
      it { is_expected.to eq("project failure") }
    end

    describe '#status_in_words' do
      subject { super().status_in_words }
      it { is_expected.to eq("failure") }
    end
  end

  context "the project has a success status" do
    before { project.stub(state: Project::State.success) }

    describe '#css_class' do
      subject { super().css_class }
      it { is_expected.to eq("project success") }
    end

    describe '#status_in_words' do
      subject { super().status_in_words }
      it { is_expected.to eq("success") }
    end
  end

  context "the project has no statuses" do
    before { project.stub(state: Project::State.indeterminate) }

    describe '#css_class' do
      subject { super().css_class }
      it { is_expected.to eq("project indeterminate") }
    end

    describe '#status_in_words' do
      subject { super().status_in_words }
      it { is_expected.to eq("indeterminate") }
    end
  end

  context "the project is offline" do
    before { project.stub(state: Project::State.offline) }

    describe '#css_class' do
      subject { super().css_class }
      it { is_expected.to eq("project offline") }
    end

    describe '#status_in_words' do
      subject { super().status_in_words }
      it { is_expected.to eq("offline") }
    end
  end
end
