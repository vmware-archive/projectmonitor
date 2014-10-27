require 'spec_helper'

describe SessionsController, :type => :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#new' do
    context 'when password authentication is enabled' do
      before { allow(Rails.configuration).to receive(:password_auth_enabled).and_return(true) }
      subject { get :new }

      it { is_expected.to be_success }
    end

    context 'when password authentication is disabled' do
      before { allow(Rails.configuration).to receive(:password_auth_enabled).and_return(false) }
      subject { get :new }

      it { is_expected.to redirect_to user_omniauth_authorize_url(:google_oauth2, only_path: true) }
    end
  end

end
