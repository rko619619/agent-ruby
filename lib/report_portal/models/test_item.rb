# frozen_string_literal: true

module ReportPortal
  # Represents a test item
  class TestItem
    attr_accessor :id, :closed, :launch_id, :unique_id, :name, :description, :type, :parameters, :tags, :status, :start_time

    def initialize(options = {})
      options = options.transform_keys(&:to_sym)
      @launch_id = options[:launch_id]
      @unique_id = options[:unique_id]
      @name = options[:name]
      @description = options[:description]
      @type = options[:type]
      @parameters = options[:parameters]
      @tags = options[:tags]
      @status = options[:status]
      @start_time = options[:start_time]
      @id = options[:id]
      @closed = options[:closed]
    end
  end
end
