require "logger"
require "singleton"

module HackyHAL
  class Log < Logger
    include Singleton

    attr_accessor :enabled

    class Formatter
      def call(severity, time, progname, message)
        time = time.strftime("%d/%b/%Y %H:%M:%S")
        "[#{time}] #{severity}: #{message}\n"
      end
    end

    def initialize
      super($stdout)
      self.enabled = true
      self.formatter = Formatter.new
    end

    alias_method :add_without_enabled_switch, :add
    def add(severity, message = nil, progname = nil, &block)
      add_without_enabled_switch(severity, message, progname, &block) if enabled
    end

    # for compatibility with Rack logger
    def write(string)
      self << string
    end
  end
end
