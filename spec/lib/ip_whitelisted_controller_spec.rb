require 'spec_helper'

describe IPWhitelistedController, type: :controller do

  describe '#restrict_ip_address' do
    controller do
      def index
        head :ok
      end
    end

    before do
      # Need to prevent before_filter from ruining our tests
      controller.stub(:authenticate_user!)
    end

    context 'when hitting an action' do
      let(:allow_ip_address) { '192.168.1.1' }
      before do
        ConfigHelper.stub(:get).with(:ip_whitelist).and_return([allow_ip_address])
        controller.class.send(:include, IPWhitelistedController)
      end
      subject { get :index }

      context 'when configured as a proxied request' do
        before do
          ConfigHelper.stub(:get).with(:ip_whitelist_request_proxied).and_return(true)
        end

        context 'and the HTTP_X_FORWARDED_FOR request ip address is in the whitelist' do
          before do
            request.env['HTTP_X_FORWARDED_FOR'] = allow_ip_address
          end

          it 'should return success' do
            controller.should_not_receive :restrict_access!

            subject

            response.should be_success
          end
        end

        context 'and the HTTP_X_FORWARDED_FOR request header contains the allowed ip address as the client' do
          before do
            request.env['HTTP_X_FORWARDED_FOR'] = "#{allow_ip_address}, 127.0.0.1, 203.1.1.0"
          end

          it 'should return success' do
            controller.should_not_receive :restrict_access!

            subject

            response.should be_success
          end
        end

        context 'and the HTTP_X_FORWARDED_FOR request header contains the allowed ip address as proxy' do
          before do
            request.env['HTTP_X_FORWARDED_FOR'] = "127.0.0.1, 203.1.1.0, #{allow_ip_address}"
          end

          it 'should authenticate the user' do
            controller.should_receive :restrict_access!

            subject
          end
        end

        context 'and the HTTP_X_FORWARDED_FOR request ip address is NOT in the whitelist' do
          before do
            request.env['HTTP_X_FORWARDED_FOR'] = "127.0.0.1"
          end

          it 'should authenticate the user' do
            controller.should_receive :restrict_access!

            subject
          end
        end

        context 'and the HTTP_X_FORWARDED_FOR request ip address is empty' do
          it 'should authenticate the user' do
            controller.should_receive :restrict_access!

            subject
          end
        end
      end

      context 'when not configured as a proxied request' do
        before do
          ConfigHelper.stub(:get).with(:ip_whitelist_request_proxied).and_return(false)
        end

        context 'and the REMOTE_ADDR request ip address is in the whitelist' do
          before do
            request.env['REMOTE_ADDR'] = allow_ip_address
          end

          it 'should return success' do
            controller.should_not_receive :restrict_access!

            subject

            response.should be_success
          end
        end

        context 'and the REMOTE_ADDR request ip address is NOT in the whitelist' do
          before do
            request.env['REMOTE_ADDR'] = '127.0.0.1'
          end

          it 'should authenticate the user' do
            controller.should_receive :restrict_access!

            subject
          end
        end
      end

      context 'the whitelist contains ranges of ip addresses' do
        let(:allow_ip_address) { '192.168.1.1/28' }

        before do
          ConfigHelper.stub(:get).with(:ip_whitelist_request_proxied).and_return(false)
        end

        it 'should allow all ip addresses in range' do
          request.env['REMOTE_ADDR'] = '192.168.1.2'
          controller.should_not_receive :restrict_access!

          subject

          response.should be_success
        end

        it 'should authenticate the user when the ip address is outside the range' do
          request.env['REMOTE_ADDR'] = '192.168.1.16'
          controller.should_receive(:restrict_access!)

          subject
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
        before do
          ConfigHelper.stub(:get).with(:ip_whitelist).and_return(['192.168.1.1'])
        end

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
