# encoding: utf-8
require 'spec_helper'

describe User, :type => :model do

  describe "factories" do
    it "has a name" do
      expect(build(:user).name).to be_present
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:login) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to ensure_length_of(:name).is_at_most(100) }
  end

  describe ".find_first_by_auth_conditions" do
    let!(:user) { create(:user, login: "foo", email: 'foo@example.com') }

    context 'when a condition is specified' do
      ['foo', 'FOO', 'foo@example.com', 'FOO@EXAMPLE.COM'].each do |condition|
        subject { User.find_first_by_auth_conditions(login: condition) }
        it { is_expected.to eq(user) }
      end
    end

    context 'when no condition is specified' do
      subject { User.find_first_by_auth_conditions({}) }

      it "returns the first user" do
        expect(User).to receive(:where).with({}).and_return(double(first: user))
        expect(subject).to eq(user)
      end
    end
  end

  describe '.find_for_google_oauth2' do
    let(:access_token) { double(:access_token, info: {"email" => 'foo@example.com', "name" => 'foo'}) }
    subject { User.find_for_google_oauth2(access_token) }

    context "when the user exists" do
      let!(:user) { create(:user, login: "foo", email: 'foo@example.com') }
      it { is_expected.to eq(user) }
    end

    context "when the user does not exist" do
      it "should create a user" do
        user = nil
        expect { user = subject }.to change { User.count }.by(1)

        expect(user.name).to eq('foo')
        expect(user.email).to eq('foo@example.com')
        expect(user.login).to eq('foo')
      end
    end
  end

end
