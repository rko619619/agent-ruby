# frozen_string_literal: true

require 'cucumber'
require 'cucumber/formatter/pretty'
require 'securerandom'
require 'tree'
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

      def on_gherkin_source_read(event)
        super(event)
        binding.irb
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
    end
  end
end
