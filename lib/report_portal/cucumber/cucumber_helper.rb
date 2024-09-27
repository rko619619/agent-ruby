# frozen_string_literal: true

require 'securerandom'
require 'tree'
require_relative '../../reportportal'

module ReportPortal
  module Cucumber
    class CucumberHelper
      MAX_DESCRIPTION_LENGTH = 255
      MIN_DESCRIPTION_LENGTH = 3

      def initialize
        @root_node = Tree::TreeNode.new(SecureRandom.hex, "Launch")
        @parent_item_node = @root_node
      end

      def start_launch
        ReportPortal.start_launch
      end

      def finish_suite
        ReportPortal.finish_suite(@parent_item_node)
      end

      def finish_launch
        ReportPortal.finish_launch
      end

      def test_case_started(test_case:)
        return unless valid_description?(test_case.name)

        test_case_item = create_test_item(
          name: test_case.name,
          type: :TEST,
          tags: extract_tag_names(test_case.tags),
          description: test_case.name
        )

        @child_item_node = add_to_tree(test_case_item)
        @child_item_node.content.id = ReportPortal.start_test_case(test_case_node: @child_item_node)
      end

      def test_case_finished(test_case_result:)
        return unless @child_item_node

        finalize_test_item(@child_item_node, test_case_result)
        @parent_item_node.remove!(@child_item_node)
        @child_item_node = nil
      end

      def test_step_finished(test_step:, test_step_result:)
        return if test_step.hook?

        log_message = build_step_log(test_step.text, test_step_result)
        ReportPortal.send_log(test_step_result.to_sym, log_message, test_step_result.duration.nanoseconds)
      end

      def feature_suite_started(feature:)
        return unless valid_description?(feature.name)

        existing_suite_node = find_existing_suite_node(feature.name)

        if existing_suite_node
          @parent_item_node = existing_suite_node
        else
          finish_previous_suite
          suite_item = create_test_item(
            name: feature.name,
            type: :SUITE,
            tags: extract_tag_names(feature.tags),
            description: feature.name
          )
          @parent_item_node = add_suite_to_tree(suite_item)
        end
      end

      private

      def valid_description?(name)
        name.size >= MIN_DESCRIPTION_LENGTH
      end

      def extract_tag_names(tags)
        tags.map(&:name)
      end

      def create_test_item(name:, type:, tags:, description:)
        ReportPortal::TestItem.new(
          name: name[0..MAX_DESCRIPTION_LENGTH - 1],
          type: type,
          start_time: ReportPortal.now,
          description: description,
          tags: tags
        )
      end

      def add_to_tree(item)
        node = Tree::TreeNode.new(SecureRandom.hex, item)
        @parent_item_node << node
        node
      end

      def finalize_test_item(node, result)
        node.content.status = result.to_sym
        ReportPortal.test_case_finished(test_case_node: node)
      end

      def build_step_log(message, result)
        result.to_sym == :passed ? message : "#{message} - \nException: #{result.exception}"
      end

      def find_existing_suite_node(feature_name)
        @root_node.breadth_each.find do |node|
          node.content.is_a?(ReportPortal::TestItem) && node.content.name == feature_name
        end
      end

      def finish_previous_suite
        return if @parent_item_node.parent.nil?

        ReportPortal.finish_suite(@parent_item_node)
      end

      def add_suite_to_tree(suite_item)
        suite_node = Tree::TreeNode.new(SecureRandom.hex, suite_item)
        if suite_node.nil?
          return @parent_item_node
        end

        @root_node << suite_node
        suite_node.content.id = ReportPortal.start_suite(suite_node)
        suite_node
      end
    end
  end
end
