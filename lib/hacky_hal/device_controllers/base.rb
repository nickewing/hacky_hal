require_relative "../log"

module HackyHAL
  module DeviceControllers
    class Base
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def [](value)
        @options[value]
      end

      def log(message, level = :info)
        Log.instance.send(level, "#{options[:name]}: #{message}")
      end

      protected

      def ensure_option(option_name)
        unless options[option_name]
          raise ArgumentError, "#{self.class.name} must set #{option_name} option."
        end
      end

    end
  end
end
