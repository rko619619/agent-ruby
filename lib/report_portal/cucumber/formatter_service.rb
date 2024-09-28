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
      def initialize
        @formatter_services = {
          pretty: ReportPortal::Cucumber::PrettyFormatter,
          progress: ReportPortal::Cucumber::ProgressFormatter,
          summary: ReportPortal::Cucumber::SummaryFormatter,
          message: ReportPortal::Cucumber::MessageFormatter }
        @formatter_service = @formatter_services[get_formatter_mode]
      end

      private

      def get_formatter_mode
        binding.irb
        ReportPortal::Settings.instance.formatter_mode
      end
    end
  end
end

