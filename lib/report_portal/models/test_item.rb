# frozen_string_literal: true

module ReportPortal
  # Represents a test item
  class TestItem
    attr_accessor :id, :closed, :launch_id, :unique_id, :name, :description, :type, :parameters, :tags, :status, :start_time

    # Initializes the test item with the provided options
    def initialize(options = {})
      assign_attributes(options)
    end

    private

    # Assigns attributes from the provided options hash
    def assign_attributes(options)
      options = options.transform_keys(&:to_sym)
      @name = options[:name]
      @type = options[:type]
      @start_time = options[:start_time]
      @description = options[:description]
      @closed = options[:closed]
    end
  end
end
