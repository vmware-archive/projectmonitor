# encoding: utf-8
require 'spec_helper'

describe User do

  describe 'validations' do
    it { should validate_presence_of(:login) }
    it { should validate_presence_of(:email) }

    # FIXME: These are probably implemented in devise and don't need to be
    # retested
    it { should allow_value('123', '1234567890_234567890_234567890_234567890',
                            'hello.-_there@funnychar.com').for(:login) }
    it { should_not allow_value('1',
                                '1234567890_234567890_234567890_234567890_',
                                "tab\t", "newline\n", "Iñtërnâtiônàlizætiøn
                                hasn't happened to ruby 1.8 yet", 'semicolon;',
                                'quote"', 'tick\'', 'backtick`', 'percent%',
                                'plus+', 'space ').for(:login) }

    it { should allow_value('foo@bar.com', 'foo@newskool-tld.museum',
                            'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
                            'r@a.wk',
                            '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
                            'hello.-_there@funnychar.com',
                            'uucp%addr@gmail.com',
                            'hello+routing-str@gmail.com',
                            'domain@can.haz.many.sub.doma.in',
                            'student.name@university.edu').for(:email) }
    it { should_not allow_value('!!@nobadchars.com', 'foo@no-rep-dots..com',
                                'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
                                'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email',
                                'need.domain.and.tld@de', "tab\t", "newline\n",
                                'r@.wk',
                                '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
     # these are technically allowed but not seen in practice:
                                'uucp!addr@gmail.com', 'semicolon;@gmail.com',
                                'quote"@gmail.com', 'tick\'@gmail.com',
                                'backtick`@gmail.com', 'space @gmail.com',
                                'bracket<@gmail.com',
                                'bracket>@gmail.com').for(:email) }

    it { should allow_value('Andre The Giant (7\'4", 520 lb.) -- has a posse',
                            '',
                            '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890').for(:name) }
    it { should_not allow_value("tab\t", "newline\n",
                                '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_').for(:name) }

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
