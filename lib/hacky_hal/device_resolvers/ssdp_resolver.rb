require_relative "base"
require "uri"
require "upnp/ssdp"

module HackyHAL
  module DeviceResolvers
    class SsdpUnresolvedDevice < Exception; end

    class SsdpResolver < Base
      def initialize(search, usn)
        @search = search
        @usn = usn
      end

      def uri
        @uri ||= (
          device = UPnP::SSDP.search(@search).find do |device|
            device[:usn] == @usn
          end

          raise SsdpUnresolvedDevice unless device
          URI.parse(device[:location])
        )
      end
    end
  end
end
