require_relative "base"
require "uri"

module HackyHAL
  module DeviceResolvers
    class StaticURI < Base
      attr_reader :uri

      def initialize(options)
        super(options)
        ensure_option(:uri)

        @uri = URI.parse(options[:uri])
      end
    end
  end
end
