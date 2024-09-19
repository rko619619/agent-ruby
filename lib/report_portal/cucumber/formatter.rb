# frozen_string_literal: true
require 'irb'
binding.irb
require 'cucumber'
require 'fileutils'

module ReportPortal
  module Cucumber
    class Formatter < Cucumber::Formatter::Pretty
      def initialize(config)
        binding.irb
        super(config)
      end
    end
  end
end