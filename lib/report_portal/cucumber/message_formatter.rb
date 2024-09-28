# frozen_string_literal: true

require 'cucumber/formatter/message'
require_relative '../../cucumber_helper'

module ReportPortal
  module Cucumber
    # Report Portal with message formatter
    class MessageFormatter < ::Cucumber::Formatter::Message
      def initialize(config)
        super(config)
        @cucumber_helper = CucumberHelper.new
        puts 'Message'
      end
    end
  end
end
