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
        ReportPortal.start_launch(description: nil)
      end

      # def on_step_activated(event)
      #   binding.irb
      #   puts 123123123123123123
      #   super(event)
      #
      #   binding.irb
      # end

      def on_test_run_finished(event)
        super(event)
        ReportPortal.finish_launch
      end

      # def collect_undefined_parameter_type_names(event)
      #   super(event)
      #   binding.irb
      # end
    end
  end
end
