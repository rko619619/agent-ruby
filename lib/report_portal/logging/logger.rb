# frozen_string_literal: true

require 'logger'

module ReportPortal
  class LoggerPatch
    def self.patch
      Logger.class_eval do
        alias_method :original_add, :add
        alias_method :original_write, :<<

        def add(severity, message = nil, progname = nil, &block)
          result = original_add(severity, message, progname, &block)
          log_message(severity, message, progname) unless severity < @level
          result
        end

        def <<(msg)
          result = original_write(msg)
          ReportPortal.send_log(ReportPortal::LOG_LEVELS[:unknown], msg.to_s, ReportPortal.now)
          result
        end

        private

        def log_message(severity, message, progname)
          progname ||= @progname
          message ||= block_given? ? yield : progname
          formatted_severity = format_severity(severity)
          formatted_message = format_message(formatted_severity, Time.now, progname, message.to_s)
          ReportPortal.send_log(formatted_severity, formatted_message, ReportPortal.now)
        end
      end
    end
  end

  LoggerPatch.patch
end
