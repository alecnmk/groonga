require "context/error_level"
require "context/rc"

module Groonga
  class Context
    def guard(fallback=nil)
      begin
        yield
      rescue => error
        logger.log_error(error)
        fallback
      end
    end

    def logger
      @logger ||= Logger.new
    end

    def query_logger
      @query_logger ||= QueryLogger.new
    end

    def writer
      @writer ||= Writer.new
    end

    def set_groonga_error(groonga_error)
      set_error_raw(groonga_error.class.rc,
                    ErrorLevel::ERROR,
                    groonga_error.message,
                    # TODO: Re-enable backtrace after mruby/mruby#2917 has been merged
                    nil) # groonga_error.backtrace)
    end

    def record_error(rc, error)
      rc = RC.find(rc) if rc.is_a?(Symbol)
      # TODO: Re-enable backtrace after mruby/mruby#2917 has been merged
      set_error_raw(rc, ErrorLevel::ERROR, error.message, nil) # error.backtrace)

      logger.log_error(error)
    end

    def with_command_version(version)
      old_version = command_version
      begin
        self.command_version = version
        yield
      ensure
        self.command_version = old_version
      end
    end

    private
    def set_error_raw(rc, error_level, message, backtrace)
      self.rc = rc.to_i
      self.error_level = error_level.to_i

      self.error_message = message

      if backtrace
        entry = BacktraceEntry.parse(backtrace.first)
        self.error_file = entry.file
        self.error_line = entry.line
        self.error_method = entry.method
      end
    end
  end
end
