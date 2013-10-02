require_relative "base"
require "uri"

module HackyHAL
  module DeviceResolvers
    class StaticResolver < Base
      attr_reader :uri

      def initialize(uri)
        @uri = URI.parse(uri)
      end
    end
  end
end
