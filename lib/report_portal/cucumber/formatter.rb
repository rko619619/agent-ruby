# frozen_string_literal: true

require 'cucumber/formatter/pretty'
require 'irb'
require_relative '../../reportportal'
require_relative 'cucumber_helper'

module ReportPortal
  module Cucumber
    # report portal formatter with pretty for cucumber
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
        @cucumber_helper.test_case_started(test_case: event.test_case)
      end

      def on_test_case_finished(event)
        super(event)
        @cucumber_helper.test_case_finished(test_case_result: event.result)
      end

      def on_test_step_started(event)
        super(event)
        @cucumber_helper.test_step_started(test_step: event.test_step)
      end

      def on_test_step_finished(event)
        super(event)
        @cucumber_helper.test_step_finished(test_step: event.result)
      end
    end
  end
end
