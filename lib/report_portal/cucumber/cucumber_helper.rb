# frozen_string_literal: true

require 'securerandom'
require 'tree'
require 'irb'
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
      test_step
      <Cucumber::Core::Test::HookStep

      def finish_suite
        ReportPortal.finish_suite(@parent_item_node)
      end

      def finish_launch
        ReportPortal.finish_launch
      end

      def test_case_started(test_case:)
        test_case_name = test_case.name
        test_case_tags = test_case.tags
        tag_names = test_case_tags.map(&:name)

        return if test_case_name.size < MIN_DESCRIPTION_LENGTH

        test_case_item = ReportPortal::TestItem.new(
          name: test_case_name[0..MAX_DESCRIPTION_LENGTH - 1],
          type: :TEST,
          start_time: ReportPortal.now,
          description: test_case_name,
          tags: tag_names
        )

        test_case_node = Tree::TreeNode.new(SecureRandom.hex, test_case_item)
        @parent_item_node << test_case_node
        @child_item_node = test_case_node

        test_case_node.content.id = ReportPortal.start_test_case(test_case_node: test_case_node)
      end

      def test_case_finished(test_case_result:)
        return unless @child_item_node

        @child_item_node.content.status = test_case_result.to_sym

        ReportPortal.test_case_finished(test_case_node: @child_item_node)

        @parent_item_node.remove!(@child_item_node)

        @child_item_node = nil
      end

      def test_step_started(test_step:)
        unless test_step.hook?
          step_name = test_step.name

          step_item = ReportPortal::TestItem.new(
            name: step_name[0..MAX_DESCRIPTION_LENGTH - 1],
            type: :STEP,
            start_time: ReportPortal.now,
            description: step_name
          )

          step_node = Tree::TreeNode.new(SecureRandom.hex, step_item)
          @child_item_node << step_node

          ReportPortal.start_step(step_node: step_node)

          @current_step_node = step_node
        end
      end

      def test_step_finished(test_step:)
        return unless @current_step_node

        @current_step_node.content.status = test_step.status.to_sym  # Set status of the step

        ReportPortal.step_finished(step_node: @current_step_node)

        # Remove the step node from the parent item node
        @child_item_node.remove!(@current_step_node)

        # Reset the current step node
        @current_step_node = nil
      end

      def feature_suite_started(feature:)
        feature_name = feature.name
        feature_tags = feature.tags
        tag_names = feature_tags.map(&:name)

        return if feature_name.size < MIN_DESCRIPTION_LENGTH

        existing_suite_node = @root_node.breadth_each.find do |node|
          if node.content.is_a?(ReportPortal::TestItem)
            node.content.name == feature_name
          else
            false
          end
        end
        if existing_suite_node
          @parent_item_node = existing_suite_node
        else
          unless @parent_item_node.parent.nil?
            ReportPortal.finish_suite(@parent_item_node)
          end

          suite_item = ReportPortal::TestItem.new(name: feature_name[0..MAX_DESCRIPTION_LENGTH - 1],
                                                  type: :SUITE,
                                                  start_time: ReportPortal.now,
                                                  description: feature_name,
                                                  tags: tag_names)
          suite_node = Tree::TreeNode.new(SecureRandom.hex, suite_item)

          if suite_node.nil?
            p "Сьют не может быть создан: #{suite_item.inspect}"
          else
            @root_node << suite_node
            @parent_item_node = suite_node
            suite_node.content.id = ReportPortal.start_suite(suite_node)
          end
        end
      end
    end
  end
end

