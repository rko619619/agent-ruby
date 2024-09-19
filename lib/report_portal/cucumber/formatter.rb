# frozen_string_literal: true

require 'irb'
require 'cucumber'
require 'cucumber/formatter/pretty'
require_relative '../../reportportal'
require 'fileutils'

module ReportPortal
  module Cucumber
    # Formatter for Cucumber
    class Formatter < ::Cucumber::Formatter::Pretty
      def on_gherkin_source_read(event)
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
