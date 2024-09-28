# frozen_string_literal: true

require 'cucumber/formatter/summary'
require_relative '../../cucumber_helper'

module ReportPortal
  module Cucumber
    # Report Portal with summary formatter
    class SummaryFormatter < ::Cucumber::Formatter::Summary
      def initialize(config)
        super(config)
        @cucumber_helper = CucumberHelper.new
        puts 'Summary'
      end
    end
  end
end


