require "serialport"
require_relative "base"

module HackyHAL
  module DeviceControllers
    class GenericSerialPort < Base
      MAX_READ_WRITE_RETRIES = 1

      DEFAULT_COMMAND_TIMEOUT = 3

      DEFAULT_OPTIONS = {
        baud_rate: 9600,
        data_bits: 8,
        stop_bits: 1,
        parity: SerialPort::NONE,
        flow_control: SerialPort::NONE
      }

      class CommandError < Exception; end

      attr_reader :serial_device_path, :serial_options

      def initialize(options = {})
        super(options)
        ensure_option(:serial_device_path)

        @serial_device_path = options[:serial_device_path]
        @serial_options = DEFAULT_OPTIONS.merge(options[:serial_options] || {})
      end

      def write_command(command)
        read_write_retry do
          serial_port.flush
          command = "#{command}\r\n"
          log("Wrote: #{command.inspect}", :debug)
          serial_port.write(command)
          true
        end
      end

      def read_command(timeout = DEFAULT_COMMAND_TIMEOUT)
        set_read_timeout(timeout) if timeout

        begin
          output = read_line
          log("Read: #{output.inspect}", :debug)
          handle_error if error_response?(output)
          output
        rescue EOFError
          log("Read EOFError", :warn)
          nil
        end
      end

      def disconnect
        @serial_port.close if @serial_port
        @serial_port = nil
      end

      def serial_port
        @serial_port ||= SerialPort.new(serial_device_path).tap do |s|
          s.baud = serial_options[:baud_rate]
          s.data_bits = serial_options[:data_bits]
          s.stop_bits = serial_options[:stop_bits]
          s.parity = serial_options[:parity]
          s.flow_control = serial_options[:flow_control]
        end
      end

      protected

      def read_write_retry
        retries = 0

        begin
          yield
        rescue Errno::EIO => e
          if retries < MAX_READ_WRITE_RETRIES
            retries += 1
            disconnect
            retry
          else
            raise e
          end
        end
      end

      def handle_error
        raise CommandError, "Serial device returned an error."
      end

      def set_read_timeout(timeout)
        serial_port.read_timeout = timeout * 1000
      end

      def read_line
        read_write_retry do
          serial_port.readline
        end
      end

      def error_response?(response)
        false
      end

    end
  end
end
