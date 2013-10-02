require_relative "generic_serial_port"

module HackyHAL
  module DeviceControllers
    class IoGearAviorHdmiSwitch < GenericSerialPort

      SERIAL_PORT_OPTIONS = {
        baud_rate: 19200,
        data_bits: 8,
        stop_bits: 1,
        parity: SerialPort::NONE,
        flow_control: SerialPort::NONE
      }

      def initialize(options = {})
        options[:serial_options] = SERIAL_PORT_OPTIONS
        super(options)
      end

      def input=(value)
        unless value.is_a?(Fixnum)
          raise ArgumentError, "Input value must be an integer."
        end

        unless value > 0
          raise ArgumentError, "Input value must be positive."
        end

        value = value.to_s.rjust(2, "0")
        write_command("sw i#{value}")
        read_command
      end

      def switch_to_next_input
        write_command("sw +")
        read_command
      end

      def switch_to_previous_input
        write_command("sw -")
        read_command
      end

      def power_on_detection=(value)
        value = value ? "on" : "off"
        write_command("pod #{value}")
        read_command
      end

      private

      # overrides GenericSerialPort#error_response?
      def error_response?(response)
        response =~ /Command incorrect/
      end
    end
  end
end
