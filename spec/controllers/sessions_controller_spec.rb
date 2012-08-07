require 'spec_helper'

describe SessionsController do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe '#new' do
    context 'when password authentication is enabled' do
      before { Rails.configuration.stub(:password_auth_enabled).and_return(true) }
      subject { get :new }

      it { should be_success }
    end

    context 'when password authentication is disabled' do
      before { Rails.configuration.stub(:password_auth_enabled).and_return(false) }
      subject { get :new }

      it { should redirect_to user_omniauth_authorize_url(:google_oauth2) }
    end
  end

end
