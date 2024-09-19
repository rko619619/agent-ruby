# frozen_string_literal: true

require 'cucumber'
require 'cucumber/formatter/pretty'
require 'securerandom'
require 'tree'
require 'irb'
require_relative '../../reportportal'

module ReportPortal
  module Cucumber
    class Formatter < ::Cucumber::Formatter::Pretty
      MAX_DESCRIPTION_LENGTH = 255
      MIN_DESCRIPTION_LENGTH = 3

      def initialize(config)
        super(config)

        @root_node = Tree::TreeNode.new(SecureRandom.hex, "Launch")
        @parent_item_node = @root_node # Родительским узлом по умолчанию будет корень (лаунч)
      end

      def on_gherkin_source_read(event)
        super(event)
        ReportPortal.start_launch(description: 'Test Launch')
      end

      def on_test_run_finished(event)
        super(event)
        ReportPortal.finish_launch
      end

      def on_test_case_started(event)
        super(event)
        feature_suite_started(feature: gherkin_document.feature)
      end

      private

      def feature_suite_started(feature:)
        feature_name = feature.name
        feature_tags = feature.tags
        tag_names = feature_tags.map(&:name)

        if feature_name.size < MIN_DESCRIPTION_LENGTH
          p "Описание группы должно содержать минимум #{MIN_DESCRIPTION_LENGTH} символов ('group_notification': #{feature.inspect})"
          return
        end

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
          ReportPortal.finish_suite(@parent_item_node)

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
