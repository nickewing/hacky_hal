require_relative "generic_ssh"

module HackyHAL
  module DeviceControllers
    class OsxComputer < GenericSsh

      # The #wake_display and #sleep_display methods require the
      # sleep-wake-display command.  You can find it here:
      # https://github.com/byteclub/os-x-sleep-wake-display

      def wake_display
        exec("sleep-wake-display wake")
      end

      def sleep_display
        exec("sleep-wake-display sleep")
      end

      # The #mirror_screens and #unmirror_screens methods require the 'displays'
      # command line tool to be installed.  You can find it here:
      # https://github.com/bwesterb/displays/

      def mirror_screens
        exec("displays mirror")
      end

      def unmirror_screens
        exec("displays unmirror")
      end

      # The #set_audio_output_device method requires the audiodevice command
      # from "Who's hacks?".  You can find it here:
      # http://whoshacks.blogspot.com/2009/01/change-audio-devices-via-shell-script.html

      def set_audio_output_device(name)
        exec("audiodevice output '#{name}'")
      end
    end
  end
end
