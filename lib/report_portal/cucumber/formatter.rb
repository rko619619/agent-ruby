# frozen_string_literal: true

require 'irb'
require 'cucumber'
require 'cucumber/formatter/pretty'
binding.irb
require 'reportportal'
require 'fileutils'

module ReportPortal
  module Cucumber
    binding.pry
    # Formatter for Cucumber
    class Formatter < AAA
      def initialize(config)
        super(config)
      end

      def on_gherkin_source_read(event)
        binding.irb
        super(event)
        ReportPortal.start_launch(description: '123')
      end

      def on_test_case_started(event)
        binding.irb
        puts 123123123123123123
        super(event)

        binding.irb
      end
    end
  end
end
