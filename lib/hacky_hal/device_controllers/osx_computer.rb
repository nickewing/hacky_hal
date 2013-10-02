require_relative "generic_ssh"

module HackyHAL
  module DeviceControllers
    class OsxComputer < GenericSsh
      def mirror_screens
        exec("mirror -on")
      end

      def unmirror_screens
        exec("mirror -off")
      end

      def set_audio_output_device(name)
        exec("audiodevice output '#{name}'")
      end
    end
  end
end
