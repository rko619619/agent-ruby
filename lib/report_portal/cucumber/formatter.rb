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
          pretty: ReportPortal::Cucumber::PrettyFormatter,
          progress: ReportPortal::Cucumber::ProgressFormatter,
          summary: ReportPortal::Cucumber::SummaryFormatter,
          message: ReportPortal::Cucumber::MessageFormatter
        }
        formatter_class = @formatter_services[get_formatter_mode]
        @formatter_service = formatter_class.new(config)
      end

      private

      def get_formatter_mode
        check_supported_mode(mode: ReportPortal::Settings.instance.formatter_mode.to_sym)
      end

      def check_supported_mode(mode:)
        binding.irb
        unless %i[pretty progress summary message].include?(mode)
          p "Unsupported formatter mode: #{mode}. Supported modes: #{@supported_formatter_modes}. Using default mode - pretty."
          mode = :pretty
        end
        mode
      end
    end
  end
end

