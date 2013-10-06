require_relative "../log"
require_relative "../options"

module HackyHAL
  module DeviceControllers
    class Base
      include Options

      def log(message, level = :info)
        Log.instance.send(level, "#{options[:name]}: #{message}")
      end
    end
  end
end
