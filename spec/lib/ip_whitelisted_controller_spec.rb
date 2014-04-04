require 'spec_helper'

describe IPWhitelistedController, type: :request do
  before :all do
    ENV["ip_whitelist"] = "['8.8.8.8', '6.6.6.6/28']"

    # Dynamically define a controller after configuring ip whitelist(see above).
    # The existing controllers are loaded before its configured and it causes this
    # module not to do anything.
    class AdminDashboardController < ApplicationController
      include IPWhitelistedController and skip_filter :authenticate_user!
      def index; head :ok; end
    end

    app.routes.eval_block ->{ get 'admin_dashboard', to: "admin_dashboard#index" }
  end

  after :all do
    ENV.delete("ip_whitelist")
    ENV.delete("ip_whitelist_request_proxied")
  end

  describe '#restrict_ip_address' do
    context 'in proxy mode' do
      before(:all) { ENV["ip_whitelist_request_proxied"] = 'true' }

      context 'when the proxy IP list is empty' do
        it 'should deny access' do
          get '/admin_dashboard', nil, 'HTTP_X_FORWARDED_FOR' => nil
          expect(response).to be_redirect
        end
      end

      context 'when the proxy IP list is not empty' do
        context "and the client IP is in the whitelist" do
          it 'should allow access' do
            get '/admin_dashboard', nil, 'HTTP_X_FORWARDED_FOR' => '8.8.8.8'
            expect(response).to be_success
          end
        end

        context "and the client IP is not in the whitelist" do
          it 'should deny access' do
            get '/admin_dashboard', nil, 'HTTP_X_FORWARDED_FOR' => '1.1.1.1'
            expect(response).to be_redirect
          end
        end

        context "and the client IP is in the whitelist range" do
          it 'should allow access' do
            get '/admin_dashboard', nil, 'HTTP_X_FORWARDED_FOR' => '6.6.6.15'
            expect(response).to be_success
          end
        end

        context "and the client IP is not in the whitelist range" do
          it 'should deny access' do
            get '/admin_dashboard', nil, 'HTTP_X_FORWARDED_FOR' => '6.6.6.16'
            expect(response).to be_redirect
          end
        end

        context 'when there are multiple proxy IP addresses' do
          context "and it looks like it (probably) has remote ip in the whitelist" do
            it 'should allow access' do
              get '/admin_dashboard', nil, 'HTTP_X_FORWARDED_FOR' => "8.8.8.8, 127.0.0.1, 192.168.1.1"
              expect(response).to be_success
            end
          end

          context "and the last client IP is not in the whitelist" do
            it 'should deny access' do
              get '/admin_dashboard', nil, 'HTTP_X_FORWARDED_FOR' => "192.168.1.1, 127.0.0.1, 203.1.1.0"
              expect(response).to be_redirect
            end
          end
        end
      end
    end

    context 'not in proxy mode' do
      before(:all) { ENV["ip_whitelist_request_proxied"] = 'false' }

      context 'when the client IP is missing' do
        it 'should deny access' do
          get '/admin_dashboard', nil, 'REMOTE_ADDR' => nil
          expect(response).to be_redirect
        end
      end

      context 'when the client IP is present' do
        context 'and the client IP is in the whitelist' do
          it 'should allow access' do
            get '/admin_dashboard', nil, 'REMOTE_ADDR' => '8.8.8.8'
            expect(response).to be_success
          end
        end

        context 'and the client IP is not in the whitelist' do
          it 'should deny access' do
            get '/admin_dashboard', nil, 'REMOTE_ADDR' => '173.194.43.2'
            expect(response).to be_redirect
          end
        end

        context 'and the client IP is in the whitelist range' do
          it 'should allow all ip addresses in range' do
            get '/admin_dashboard', nil, 'REMOTE_ADDR' => '6.6.6.15'
            expect(response).to be_success
          end

          context 'and the client IP is outside the whitelist range' do
            it 'should deny access' do
              get '/admin_dashboard', nil, 'REMOTE_ADDR' => '6.6.6.16'
              expect(response).to be_redirect
            end
          end
        end
      end
    end
  end

  describe '.included' do
    let(:whitelisted_controller) { Class.new }

    before do
      whitelisted_controller.stub(:before_filter)
    end

    context 'an ip whitelist is specified' do
      context 'the whitelist contains single ip addresses' do
        it 'should add the authentication before filter' do
          whitelisted_controller.should_receive(:before_filter).with(:authenticate_user!)
          whitelisted_controller.send(:include, IPWhitelistedController)
        end

        it 'should add the ip whitelist before filter' do
          whitelisted_controller.should_receive(:before_filter).with(:restrict_ip_address)
          whitelisted_controller.send(:include, IPWhitelistedController)
        end
      end
    end

    context 'no ip whitelist is specified' do
      before do
        ConfigHelper.stub(:get).with(:ip_whitelist).and_return(nil)
      end

      it 'should not add any filters' do
        whitelisted_controller.should_not_receive(:before_filter)
        whitelisted_controller.send(:include, IPWhitelistedController)
      end
    end
  end
end
