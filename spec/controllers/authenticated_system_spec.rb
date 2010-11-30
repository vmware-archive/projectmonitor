require 'spec_helper'

describe SessionsController do
  include AuthenticatedSystem
  fixtures :users

  def action_name()
  end

  before do
    stub!(:authenticate_with_http_basic).and_return nil
  end

  describe "logout_killing_session!" do
    before do
      login_as :quentin
      stub!(:reset_session)
    end

    it 'resets the session' do
      should_receive(:reset_session); logout_killing_session!
    end

    it 'kills my auth_token cookie' do
      should_receive(:kill_remember_cookie!); logout_killing_session!
    end

    it 'nils the current user' do
      logout_killing_session!; current_user.should be_nil
    end

    it 'kills :user_id session' do
      session.stub!(:[]=)
      session.should_receive(:[]=).with(:user_id, nil).at_least(:once)
      logout_killing_session!
    end
  end

  describe "logout_keeping_session!" do
    before do
      login_as :quentin
      stub!(:reset_session)
    end

    it 'does not reset the session' do
      should_not_receive(:reset_session); logout_keeping_session!
    end

    it 'kills my auth_token cookie' do
      should_receive(:kill_remember_cookie!); logout_keeping_session!
    end

    it 'nils the current user' do
      logout_keeping_session!; current_user.should be_nil
    end

    it 'kills :user_id session' do
      session.stub!(:[]=)
      session.should_receive(:[]=).with(:user_id, nil).at_least(:once)
      logout_keeping_session!
    end
  end

  describe 'When logged out' do
    it "should not be authorized?" do
      authorized?().should be_false
    end
  end

end
