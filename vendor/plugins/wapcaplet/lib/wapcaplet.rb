require "action_controller/test_process"

module Wapcaplet
  module TestRequest
    def self.included(klass)
      klass.class_eval do
        remove_method :assign_parameters
        include InstanceMethods
      end
    end

    module InstanceMethods
      def assign_parameters(controller_path, action, parameters)
        parameters = parameters.symbolize_keys.merge(:controller => controller_path, :action => action)
        extra_keys = ActionController::Routing::Routes.extra_keys(parameters)
        non_path_parameters = get? ? query_parameters : request_parameters
        parameters.each do |key, value|
          value = ActionController::Routing::PathSegment::Result.new(value) if value.is_a? Array

          if extra_keys.include?(key.to_sym)
            verify_proper_param(value)
            non_path_parameters[key] = value
          else
            verify_proper_param(value, :route_param)
            path_parameters[key.to_s] = value
          end
        end
        raw_post # populate env['RAW_POST_DATA']
        @parameters = nil # reset TestRequest#parameters to use the new path_parameters
      end

      private

      def verify_proper_param(value, route_param = false)
        case value
          when Hash
            value.values.each { |element| verify_proper_param(element) }
          when Array
            value.each { |element| verify_proper_param(element) }
          when String, ActionController::TestUploadedFile, NilClass
          when ActiveRecord::Base
            raise ArgumentError.new("ActiveRecords are only valid as value for routing path parameters") unless route_param
          else
            raise ArgumentError.new("Test requests should have only string or file upload parameters")
        end
      end
    end
  end
end

ActionController::TestRequest.class_eval { include Wapcaplet::TestRequest }
