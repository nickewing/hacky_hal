require_relative "base"
require "uri"
require "upnp/ssdp"

module HackyHAL
  module DeviceResolvers
    class SsdpUnresolvedDevice < Exception; end

    DEFAULT_OPTIONS = {
      search: "upnp:rootdevice"
    }

    class SSDP < Base
      def initialize(options)
        super(DEFAULT_OPTIONS.merge(options))
        ensure_option(:usn)
      end

      def uri
        @uri ||= (
          old_upnp_log_value = UPnP.log?
          UPnP.log = false

          device = UPnP::SSDP.search(options[:search]).find do |device|
            device[:usn] == options[:usn]
          end

          UPnP.log = old_upnp_log_value

          raise SsdpUnresolvedDevice unless device
          URI.parse(device[:location])
        )
      end
    end
  end
end
