# frozen_string_literal: true

require 'yaml'
require 'singleton'
require 'irb'

module ReportPortal
  class Settings
    include Singleton

    def initialize
      @filename = get_settings_file
      @properties = @filename.nil? ? {} : YAML.load_file(@filename)
      keys = {
        'uuid' => true,
        'endpoint' => true,
        'project' => true,
        'launch' => true,
        'tags' => false,
        'description' => false,
        'attributes' => false,
        'cucumber_formatter' => false
      }

      keys.each do |key, is_required|
        define_singleton_method(key.to_sym) { setting(key) }
        next unless is_required && public_send(key).nil?

        env_variable_name = env_variable_name(key)
        raise "ReportPortal: Define environment variable '#{env_variable_name.upcase}', '#{env_variable_name}' "\
          "or key #{key} in the configuration YAML file"
      end
    end

    def cucumber_formatter
      setting('cucumber_formatter')&.to_sym
    end


    def setting(key)
      env_variable_name = env_variable_name(key)
      return YAML.safe_load(ENV[env_variable_name.upcase]) if ENV.key?(env_variable_name.upcase)

      return YAML.safe_load(ENV[env_variable_name]) if ENV.key?(env_variable_name)

      @properties[key]
    end

    def env_variable_name(key)
      "rp_#{key}"
    end
  end
end
