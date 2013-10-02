require_relative "generic_serial_port"

module HackyHAL
  module DeviceControllers
    class EpsonProjector < GenericSerialPort

      SERIAL_PORT_OPTIONS = {
        baud_rate: 9600,
        data_bits: 8,
        stop_bits: 1,
        parity: SerialPort::NONE,
        flow_control: SerialPort::NONE
      }

      SOURCE_COMMAND_TIMEOUT = 5

      POWER_STATUS_TO_SYMBOL = {
        "00" => :standby, # standby, network off
        "01" => :on,
        "02" => :warming_up,
        "03" => :cooling_down,
        "04" => :standby, # standby, network on
        "05" => :standby # standby, abnormal
      }

      DEVICE_SOURCE_ID_TO_NAME = {
        "HC8350" => {
          "30" => "HDMI1",
          "A0" => "HDMI2",
          "14" => "Component (YCbCr)",
          "15" => "Component (YPbPr)",
          "21" => "PC",
          "41" => "Video (RCA)",
          "42" => "S-Video"
        }
      }

      DEVICE_CMODE_ID_TO_NAME = {
        "HC8350" => {
          "06" => "Dynamic",
          "0C" => "Living Room",
          "07" => "Natural",
          "15" => "Cinema",
          "0B" => "x.v.Color"
        }
      }

      DEVICE_ASPECT_RATIO_ID_TO_NAME = {
        "HC8350" => {
          "00" => "Normal"
        }
      }

      ERROR_CODE_TO_MESSAGE = {
        "00" => "There is no error or the error is recovered",
        "01" => "Fan error",
        "03" => "Lamp failure at power on",
        "04" => "High internal temperature error",
        "06" => "Lamp error",
        "07" => "Open Lamp cover door error",
        "08" => "Cinema filter error",
        "09" => "Electric dual-layered capacitor is disconnected",
        "0A" => "Auto iris error",
        "0B" => "Subsystem Error",
        "0C" => "Low air flow error",
        "0D" => "Air filter air flow sensor error",
        "0E" => "Power supply unit error (Ballast)",
        "0F" => "Shutter error",
        "10" => "Cooling system error (peltiert element)",
        "11" => "Cooling system error (Pump)"
      }

      attr_reader :model

      def initialize(options = {})
        options[:serial_options] = SERIAL_PORT_OPTIONS
        super(options)
        @model = options[:model]
      end

      def on
        power_status == :on
      end

      def on=(value)
        value = value ? "ON" : "OFF"
        write_command("PWR #{value}")
        read_command(1)
      end

      def power_status
        write_command("PWR?")
        status_code = get_command_output(read_command)
        POWER_STATUS_TO_SYMBOL[status_code] || :unknown
      end

      def lamp_hours
        write_command("LAMP?")
        get_command_output(read_command).to_i
      end

      def source
        write_command("SOURCE?")
        source_id = get_command_output(read_command)

        source_name_hash = DEVICE_SOURCE_ID_TO_NAME[model]
        source_name = source_name_hash[source_id] || "Unknown"

        {id: source_id, name: source_name}
      end

      def source=(source_id)
        write_command("SOURCE #{source_id}")
        read_command(SOURCE_COMMAND_TIMEOUT)
      end

      def color_mode
        write_command("CMODE?")
        color_mode_id = get_command_output(read_command)

        color_mode_hash = DEVICE_CMODE_ID_TO_NAME[model]
        color_mode_name = color_mode_hash[color_mode_id] || "Unknown"

        {id: color_mode_id, name: color_mode_name}
      end

      def color_mode=(color_mode_id)
        write_command("CMODE #{color_mode_id}")
        read_command
      end

      def aspect_ratio
        write_command("ASPECT?")
        aspect_ratio_id = get_command_output(read_command)
        
        aspect_ratio_hash = DEVICE_ASPECT_RATIO_ID_TO_NAME[model]
        aspect_ratio_name = aspect_ratio_hash[aspect_ratio_id] || "Unknown"

        {id: aspect_ratio_id, name: aspect_ratio_name}
      end

      def aspect_ratio=(aspect_ratio_id)
        write_command("ASPECT #{aspect_ratio_id}")
        read_command
      end

      def error
        write_command("ERR?")
        set_read_timeout(DEFAULT_COMMAND_TIMEOUT)
        error_code = get_command_output(read_line)
        if error_code
          error_message = ERROR_CODE_TO_MESSAGE[error_code] || "Unknown"
          {code: error_code, message: error_message}
        end
      end

      private

      # overrides GenericSerialPort#error_response?
      def error_response?(response)
        response =~ /^:?ERR/
      end

      def handle_error
        error_details = error

        if error_details
          raise CommandError, "Projector returned error code #{error_details[:code]}: #{error_details[:message]}."
        else
          raise CommandError, "Projector returned an error."
        end
      end

      def get_command_output(output)
        output =~ /^:?\w+=(.+)\r:$/
        $1 ? $1.chomp : nil
      end
    end
  end
end
