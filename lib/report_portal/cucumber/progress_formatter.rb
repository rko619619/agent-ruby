# frozen_string_literal: true

require 'cucumber/formatter/progress'
require_relative '../../cucumber_helper'

module ReportPortal
  module Cucumber
    # Report Portal with progress formatter
    class ProgressFormatter < ::Cucumber::Formatter::Progress
      def initialize(config)
        super(config)
        @cucumber_helper = CucumberHelper.new
        puts 'Progress'
      end
    end
  end
end

