require 'spec_helper'

describe TravisProjectDecorator do

  describe '#current_build_url' do
    subject { project.decorate.current_build_url }
    let(:project) { FactoryGirl.build(:travis_project) }

    it "returns a url to the project" do
      should == 'https://travis-ci.org/account/project'
    end
  end

end
