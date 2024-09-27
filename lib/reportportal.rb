# frozen_string_literal: true

require 'base64'
require 'cgi'
require 'http'
require 'json'
require 'mime/types'
require 'pathname'
require 'tempfile'
require 'uri'

require_relative 'report_portal/event_bus'
require_relative 'report_portal/models/item_search_options'
require_relative 'report_portal/models/test_item'
require_relative 'report_portal/settings'
require_relative 'report_portal/http_client'

module ReportPortal
  LOG_LEVELS = { error: 'ERROR', warn: 'WARN', info: 'INFO', debug: 'DEBUG', trace: 'TRACE', fatal: 'FATAL', unknown: 'UNKNOWN' }.freeze

  class << self
    attr_accessor :launch_id, :current_scenario

    def now
      (current_time.to_f * 1000).to_i
    end

    def status_to_level(status)
      LOG_LEVELS[status] || default_status_level(status)
    end

    def start_launch(description: '123', start_time: now)
      launch_data = prepare_item_data(
        name: Settings.instance.launch,
        description: description,
        start_time: start_time,
        mode: Settings.instance.launch_mode
      )
      @launch_id = send_request(:post, 'launch', json: launch_data)['id']
    end

    def finish_launch(end_time: now)
      data = { end_time: end_time }
      @finished_launch = send_request(:put, "launch/#{@launch_id}/finish", json: data)
      log_launch_link if Settings.instance.logLaunchLink
    end

    def start_item(item_node, parent_item = nil)
      item = item_node.content
      validate_item(item, %i[start_time name type])

      path = build_item_path(parent_item)
      data = build_item_data(item, @launch_id)

      response = send_request(:post, path, json: data)
      handle_response(response, item)
    end

    def finish_item(item_node)
      item = item_node.content
      validate_item(item, [:id])

      return if item.closed

      data = { end_time: now, status: item.status }
      send_request(:put, "item/#{item.id}", json: data)
      item.closed = true
    end

    def send_log(status, message, time)
      return if @current_scenario.nil? || @current_scenario.closed

      data = {
        item_id: @current_scenario.id,
        time: time,
        level: status_to_level(status),
        message: message.to_s
      }
      send_request(:post, 'log', json: data)
    end

    def send_file(status, path_or_src, label = nil, time = now, mime_type = 'image/png')
      path_or_src = decode_base64_if_needed(path_or_src, mime_type)
      path_or_src = write_temp_file(path_or_src, mime_type) unless File.file?(path_or_src)

      send_file_from_path(status, path_or_src, label, time, mime_type)
    end

    def get_items(filter_options = {})
      fetch_paginated_results('item', filter_options) do |item_params|
        TestItem.new(item_params)
      end
    end

    def delete_items(item_ids)
      send_request(:delete, 'item', params: { ids: item_ids })
    end

    private

    def build_item_data(item, launch_id)
      {
        start_time: item.start_time,
        name: item.name[0, 255],
        type: item.type.to_s,
        launch_id: launch_id,
        description: item.description,
        tags: item.tags
      }.compact
    end

    def build_item_path(parent_item)
      return 'item' unless parent_item

      validate_item(parent_item, [:id])
      "item/#{parent_item.id}"
    end

    def handle_response(response, item)
      raise "Error in ReportPortal response: ID not found. Response: #{response.inspect}" unless response['id']

      item.id = response['id']
      item.start_time = item.start_time
    end

    def validate_item(item, required_attrs)
      missing_attrs = required_attrs.reject { |attr| item.respond_to?(attr) && !item.send(attr).nil? }
      raise "Invalid object in #{item.inspect}. Missing attributes: #{missing_attrs.join(', ')}" unless missing_attrs.empty?
    end

    def log_launch_link
      @launch_link = @finished_launch['link']
      print "Launch ID ReportPortal: #{@launch_link}"
    end

    def send_file_from_path(status, path, label, time, mime_type)
      File.open(File.realpath(path), 'rb') do |file|
        filename = File.basename(file)
        json = [{ level: status_to_level(status), message: label || filename, item_id: @current_scenario.id, time: time, file: { name: filename } }]
        form = {
          json_request_part: HTTP::FormData::Part.new(JSON.dump(json), content_type: 'application/json'),
          binary_part: HTTP::FormData::File.new(file, filename: filename, content_type: MIME::Types[mime_type].first.to_s)
        }
        send_request(:post, 'log', form: form)
      end
    end

    def fetch_paginated_results(path, filter_options, &block)
      page_size = 100
      max_pages = 100
      all_items = []

      1.step.each do |page_number|
        raise 'Too many pages with the results were returned' if page_number > max_pages

        options = ItemSearchOptions.new({ page_size: page_size, page_number: page_number }.merge(filter_options))
        page_items = send_request(:get, path, params: options.query_params)['content'].map(&block)
        all_items += page_items
        break if page_items.size < page_size
      end

      all_items
    end

    def decode_base64_if_needed(path_or_src, mime_type)
      return path_or_src unless mime_type =~ /;base64$/

      mime_type.chomp!(';base64')
      Base64.decode64(path_or_src)
    end

    def write_temp_file(content, mime_type)
      extension = ".#{MIME::Types[mime_type].first.extensions.first}"
      Tempfile.open(['report_portal', extension]) do |tempfile|
        tempfile.binmode
        tempfile.write(content)
        tempfile.rewind
        tempfile.path
      end
    end

    def send_request(verb, path, options = {})
      http_client.send_request(verb, path, options)
    end

    def http_client
      @http_client ||= HttpClient.new
    end

    def current_time
      Time.now_without_mock_time if Time.respond_to?(:now_without_mock_time) || Time.now
    end
  end
end
