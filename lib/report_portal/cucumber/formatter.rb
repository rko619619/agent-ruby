# frozen_string_literal: true

require_relative '../../cucumber_helper'
require_relative '../settings'
require_relative 'pretty_formatter'
require_relative 'progress_formatter'
require_relative 'summary_formatter'
require_relative 'message_formatter'
require 'irb'

module ReportPortal
  module Cucumber
    # Report Portal formatter service
    class Formatter
      def initialize(config)
        @formatter_services = {
          pretty: ReportPortal::Cucumber::PrettyFormatter.new(config),
          progress: ReportPortal::Cucumber::ProgressFormatter.new(config),
          summary: ReportPortal::Cucumber::SummaryFormatter.new(config),
          message: ReportPortal::Cucumber::MessageFormatter.new(config) }
        @formatter_service = @formatter_services[get_formatter_mode]
        binding.irb
      end

      private

      def get_formatter_mode
        ReportPortal::Settings.instance.formatter_mode.to_sym
      end
    end
  end
end

