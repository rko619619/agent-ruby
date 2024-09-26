# frozen_string_literal: true

require 'cucumber/formatter/pretty'
require 'irb'
require_relative '../../reportportal'
require_relative 'cucumber_helper'

module ReportPortal
  module Cucumber
    class Formatter < ::Cucumber::Formatter::Pretty
      def initialize(config)
        super(config)
        @cucumber_helper = CucumberHelper.new
      end

      def bind_events(config)
        super(config)
        config.on_event :test_run_started, &method(:on_test_run_started)
      end

      def on_test_run_started(event)
        @cucumber_helper.start_launch
      end

      def on_test_run_finished(event)
        super(event)
        @cucumber_helper.finish_suite
        @cucumber_helper.finish_launch
      end

      def on_test_case_started(event)
        super(event)
        @cucumber_helper.feature_suite_started(feature: gherkin_document.feature)
      end

      def on_test_case_finished(event)
        super(event)
        binding.irb
      end
    end
  end
end
