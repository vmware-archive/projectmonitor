require 'spec_helper'

describe IPWhitelistedController, type: :controller do
  let(:ip_whitelist) { ['192.168.1.1', '192.168.2.1/28'] }

  before { ConfigHelper.stub(:get).with(:ip_whitelist).and_return(ip_whitelist) }

  describe '#restrict_ip_address' do
    controller do
      def index
        head :ok
      end
    end

    before do
      controller.stub(:authenticate_user!)
      controller.class.send(:include, IPWhitelistedController)
    end

    context 'in proxy mode' do
      before { ConfigHelper.stub(:get).with(:ip_whitelist_request_proxied).and_return(true) }

      context 'when the proxy IP list is empty' do
        it 'should deny access' do
          request.env['HTTP_X_FORWARDED_FOR'].should be_nil
          controller.should_receive :restrict_access!
          get :index
        end
      end

      context 'when the proxy IP list is not empty' do
        context "and the client IP is in the whitelist" do
          it 'should allow access' do
            request.env['HTTP_X_FORWARDED_FOR'] = '192.168.1.1'
            controller.should_not_receive :restrict_access!
            get :index
            response.should be_success
          end
        end

        context "and the client IP is not in the whitelist" do
          it 'should deny access' do
            request.env['HTTP_X_FORWARDED_FOR'] = "1.1.1.1"
            controller.should_receive :restrict_access!
            get :index
          end
        end

        context "and the client IP is in the whitelist range" do
          it 'should allow access' do
            request.env['HTTP_X_FORWARDED_FOR'] = '192.168.2.2'
            controller.should_not_receive :restrict_access!
            get :index
            response.should be_success
          end
        end

        context "and the client IP is not in the whitelist range" do
          it 'should deny access' do
            request.env['HTTP_X_FORWARDED_FOR'] = '192.168.2.17'
            controller.should_receive :restrict_access!
            get :index
          end
        end

        context 'when there are multiple proxy IP addresses' do
          context "and the last client IP is in the whitelist" do
            it 'should allow access' do
              request.env['HTTP_X_FORWARDED_FOR'] = "127.0.0.1, 203.1.1.0, 192.168.1.1"
              controller.should_not_receive :restrict_access!
              get :index
              response.should be_success
            end
          end

          context "and the last client IP is not in the whitelist" do
            it 'should deny access' do
              request.env['HTTP_X_FORWARDED_FOR'] = "192.168.1.1, 127.0.0.1, 203.1.1.0"
              controller.should_receive :restrict_access!
              get :index
            end
          end
        end
      end
    end

    context 'not in proxy mode' do
      before { ConfigHelper.stub(:get).with(:ip_whitelist_request_proxied).and_return(false) }

      context 'when the client IP is missing' do
        it 'should deny access' do
          request.env['REMOTE_ADDR'] = nil
          controller.should_receive :restrict_access!
          get :index
        end
      end

      context 'when the client IP is present' do
        context 'and the client IP is in the whitelist' do
          it 'should allow access' do
            request.env['REMOTE_ADDR'] = '192.168.1.1'
            controller.should_not_receive :restrict_access!
            get :index
            response.should be_success
          end
        end

        context 'and the client IP is not in the whitelist' do
          it 'should deny access' do
            request.env['REMOTE_ADDR'] = '127.0.0.1'
            controller.should_receive :restrict_access!
            get :index
          end
        end

        context 'and the client IP is in the whitelist range' do
          it 'should allow all ip addresses in range' do
            request.env['REMOTE_ADDR'] = '192.168.2.2'
            controller.should_not_receive :restrict_access!
            get :index
            response.should be_success
          end

          context 'and the client IP is outside the whitelist range' do
            it 'should deny access' do
              request.env['REMOTE_ADDR'] = '192.168.2.16'
              controller.should_receive(:restrict_access!)
              get :index
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
