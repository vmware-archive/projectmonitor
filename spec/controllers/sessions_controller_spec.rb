require 'spec_helper'

describe SessionsController, :type => :controller do
  include Devise::Controllers::UrlHelpers
  include Devise::OmniAuth::UrlHelpers

  # To satisfy `omniauth_authorize_url`
  def main_app
    Rails.application.class.routes.url_helpers
  end

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

      it { is_expected.to redirect_to omniauth_authorize_url(:user, :google_oauth2, only_path: true) }
    end
  end

end
