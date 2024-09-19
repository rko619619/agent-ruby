# frozen_string_literal: true

require 'irb'
require 'cucumber'
require 'cucumber/formatter/pretty'
require 'securerandom'
require 'tree'
require_relative '../../reportportal'
require 'fileutils'

module ReportPortal
  module Cucumber
    # Formatter for Cucumber
    class Formatter < ::Cucumber::Formatter::Pretty
      def initialize(config)
        super(config)

        @root_node = Tree::TreeNode.new(SecureRandom.hex)
        @parent_item_node = @root_node
        @last_used_time = 0
      end

      def on_gherkin_source_read(event)
        super(event)
        ReportPortal.start_launch(description: nil)
      end

      def on_test_run_finished(event)
        super(event)
        ReportPortal.finish_launch
      end


      def on_test_case_started(event)
        super(event)
        feature_started(feature: gherkin_document.feature)
      end

      private

      def feature_started(feature:)
        binding.irb
        feature_description = feature.description
        feature_tags = feature.tags

        if feature_description.size < MIN_DESCRIPTION_LENGTH
          p "Group description should be at least #{MIN_DESCRIPTION_LENGTH} characters ('group_notification': #{feature.inspect})"
          return
        end

        item = ReportPortal::TestItem.new(name: feature_description[0..MAX_DESCRIPTION_LENGTH - 1],
                                          type: :SUITE,
                                          start_time: ReportPortal.now,
                                          description: feature_description,
                                          tags: feature_tags)

        group_node = Tree::TreeNode.new(SecureRandom.hex, item)
        if group_node.nil?
          p "Group node is nil for item #{item.inspect}"
        else
          @parent_item_node << group_node unless @parent_item_node.nil? # make @current_group_node parent of group_node
          @parent_item_node = group_node
          group_node.content.id = ReportPortal.start_item(group_node)
        end
      end
    end
  end
end
