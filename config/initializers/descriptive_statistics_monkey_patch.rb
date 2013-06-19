require 'descriptive-statistics'

module Enumerable
  include DescriptiveStatistics

  # Warning: hacky evil meta programming. Required because classes that have already included
  # Enumerable will not otherwise inherit the statistics methods.
  DescriptiveStatistics.instance_methods.each do |m|
    define_method(m, DescriptiveStatistics.instance_method(m))
  end
end