# encoding: utf-8
require 'spec_helper'

describe User do

  describe "factories" do
    it "has a name" do
      FactoryGirl.build(:user).name.should be_present
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:login) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_confirmation_of(:password) }
    it { should ensure_length_of(:name).is_at_most(100) }
  end


  describe ".find_first_by_auth_conditions" do
    let!(:user) { FactoryGirl.create(:user, login: "foo", email: 'foo@example.com') }

    context 'when a condition is specified' do
      ['foo', 'FOO', 'foo@example.com', 'FOO@EXAMPLE.COM'].each do |condition|
        subject { User.find_first_by_auth_conditions(login: condition) }
        it { should == user }
      end
    end

    context 'when no condition is specified' do
      subject { User.find_first_by_auth_conditions({}) }

      it "returns the first user" do
        User.should_receive(:where).with({}).and_return(double(first: user))
        subject.should == user
      end
    end
  end

  describe '.find_for_google_oauth2' do
    let(:access_token) { double(:access_token, info: {"email" => 'foo@example.com', "name" => 'foo'}) }
    subject { User.find_for_google_oauth2(access_token) }

    context "when the user exists" do
      let!(:user) { FactoryGirl.create(:user, login: "foo", email: 'foo@example.com') }
      it { should == user }
    end

    context "when the user does not exist" do
      it "should create a user" do
        User.should_receive(:create!).with(name: 'foo',  email: 'foo@example.com', login: 'foo', password: anything)
        subject
      end
    end
  end

end
