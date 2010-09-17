module Spec
  module Matchers
    def contain_exactly(collection)
      ContainExactly.new(collection)
    end

    class ContainExactly
      def initialize(collection)
        @collection = collection
        @offending_objects = []
      end

      def matches?(other_collection)
        @other_collection = other_collection
        @offending_contained_objects = @other_collection.reject do |object|
          @collection.include?(object)
        end
        @offending_uncontained_objects = @collection.reject do |object|
          @other_collection.include?(object)
        end
        @offending_contained_objects.empty? and @offending_uncontained_objects.empty?
      end

      def failure_message
        "Expected collection contained: #{@collection.inspect}\n" +
        "Actual collection contained:   #{@other_collection.inspect}\n" +
        "Missing stuff:                 #{@offending_uncontained_objects.inspect}\n" +
        "Extra stuff:                   #{@offending_contained_objects.inspect}\n"
      end
    end

  end
end

