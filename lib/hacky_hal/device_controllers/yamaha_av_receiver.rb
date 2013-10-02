require "net/http"
require "uri"
require "rexml/document"
require_relative "base"

module HackyHAL
  module DeviceControllers
    class YamahaAvReceiver < Base
      CONTROL_PATH = "/YamahaRemoteControl/ctrl"
      CONTROL_PORT = 80

      def initialize(options)
        super(options)
        ensure_option(:device_resolver)

        @host_uri = options[:device_resolver].uri
        @host_uri.path = CONTROL_PATH
        @host_uri.port = CONTROL_PORT

        log("Host found at: #{@host_uri.to_s}", :debug)
      end

      def label
        "#{super}(#{options[:control_host]})"
      end

      def basic_status
        response = get_request('<Main_Zone><Basic_Status>GetParam</Basic_Status></Main_Zone>')

        basic_settings = response.elements["YAMAHA_AV/Main_Zone/Basic_Status"]
        power_settings = basic_settings.elements["Power_Control"]
        volume_settings = basic_settings.elements["Volume"]
        input_settings = basic_settings.elements["Input/Input_Sel_Item_Info"]
        sound_video_settings = basic_settings.elements["Sound_Video"]
        hdmi_settings = sound_video_settings.elements["HDMI"]
        tone_settings = sound_video_settings.elements["Tone"]
        dialog_adjust_settings = sound_video_settings.elements["Dialogue_Adjust"]
        surround_settings = basic_settings.elements["Surround/Program_Sel/Current"]

        hdmi_output_values = []
        hdmi_settings.elements.each("Output") do |output_element|
          if output_element.name =~ /^OUT_(\d)$/
            hdmi_output_values << {
              name: output_element.name,
              enabled: element_on?(output_element)
            }
          end
        end

        {
          power: element_on?(power_settings.elements["Power"]),
          sleep: element_on?(power_settings.elements["Sleep"]),
          mute: element_on?(volume_settings.elements["Mute"]),
          volume: element_volume_value(volume_settings.elements["Lvl/Val"]),
          subwoofer_trim: element_volume_value(volume_settings.elements["Subwoofer_Trim/Val"]),
          tone: {
            base: element_volume_value(tone_settings.elements["Bass/Val"]),
            treble: element_volume_value(tone_settings.elements["Treble/Val"])
          },
          input: {
            name: input_settings.elements["Param"].text,
            title: input_settings.elements["Title"].text
          },
          surround: {
            straight: element_on?(surround_settings.elements["Straight"]),
            enhancer: element_on?(surround_settings.elements["Enhancer"]),
            sound_program: surround_settings.elements["Sound_Program"].text,
            cinema_dsp_3d_mode: element_on?(basic_settings.elements["Surround/_3D_Cinema_DSP"])
          },
          hdmi: {
            standby_through: element_on?(hdmi_settings.elements["Standby_Through_Info"]),
            outputs: hdmi_output_values
          },
          party_mode: element_on?(basic_settings.elements["Party_Info"]),
          pure_direct_mode: element_on?(sound_video_settings.elements["Pure_Direct/Mode"]),
          adaptive_drc: element_on?(sound_video_settings.elements["Adaptive_DRC"]),
          dialog_adjust: {
            level: dialog_adjust_settings.elements["Dialogue_Lvl"].text.to_i,
            lift: dialog_adjust_settings.elements["Dialogue_Lift"].text.to_i
          }
        }
      end

      def inputs
        response = get_request('<Main_Zone><Input><Input_Sel_Item>GetParam</Input_Sel_Item></Input></Main_Zone>')

        inputs = []
        response.elements["YAMAHA_AV/Main_Zone/Input/Input_Sel_Item"].each do |input_element|
          if input_element.name =~ /^Item_\d+$/
            inputs << {
              name: input_element.elements["Param"].text,
              title: input_element.elements["Title"].text,
              source_name: input_element.elements["Src_Name"].text,
              source_number: input_element.elements["Src_Number"].text.to_i,
            }
          end
        end

        inputs
      end

      def input
        response = get_request('<Main_Zone><Input><Input_Sel>GetParam</Input_Sel></Input></Main_Zone>')
        response.elements["YAMAHA_AV/Main_Zone/Input/Input_Sel"].text
      end

      def input=(input_name)
        put_request(%|<Main_Zone><Input><Input_Sel>#{input_name}</Input_Sel></Input></Main_Zone>|)
      end

      def hdmi_output(output_name)
        response = get_request(%|<System><Sound_Video><HDMI><Output><#{output_name}>GetParam</#{output_name}></Output></HDMI></Sound_Video></System>|)
        element_on?(response.elements["YAMAHA_AV/System/Sound_Video/HDMI/Output/#{output_name}"])
      end

      def set_hdmi_output(output_name, enabled)
        value = enabled ? "On" : "Off"
        put_request(%|<System><Sound_Video><HDMI><Output><#{output_name}>#{value}</#{output_name}></Output></HDMI></Sound_Video></System>|)
      end

      def on
        response = get_request("<Main_Zone><Power_Control><Power>GetParam</Power></Power_Control></Main_Zone>")
        response.elements["YAMAHA_AV/Main_Zone/Power_Control/Power"].text == "On"
      end

      def on=(value)
        value = value ? "On" : "Standby"
        put_request("<Main_Zone><Power_Control><Power>#{value}</Power></Power_Control></Main_Zone>")
      end

      def volume
        response = get_request("<Main_Zone><Volume><Lvl>GetParam</Lvl></Volume></Main_Zone>")
        element_volume_value(response.elements["YAMAHA_AV/Main_Zone/Volume/Lvl/Val"])
      end

      def volume=(value)
        value = (value * 10.0).to_i.to_s
        response = put_request("<Main_Zone><Volume><Lvl><Val>#{value}</Val><Exp>1</Exp><Unit>dB</Unit></Lvl></Volume></Main_Zone>")
      end
      
      def mute
        response = get_request("<Main_Zone><Volume><Mute>GetParam</Mute></Volume></Main_Zone>")
        element_on?(response.elements["YAMAHA_AV/Main_Zone/Volume/Mute"])
      end
      
      def mute=(value)
        value = case value
                when true then "On"
                when false then "Off"
                else value
                end

        put_request("<Main_Zone><Volume><Mute>#{value}</Mute></Volume></Main_Zone>")
      end

      private

      def request(body)
        http = Net::HTTP.new(@host_uri.host, @host_uri.port)

        request = Net::HTTP::Post.new(@host_uri.request_uri)
        request["Content-Type"] = "text/xml"
        request.body = body

        response = http.request(request)
        log("Response: #{response.body}", :debug)

        response_xml = REXML::Document.new(response.body)

        if response_xml.root.attributes["RC"] == "0"
          response_xml
        else
          false
        end
      end

      def get_request(body)
        command = %|<YAMAHA_AV cmd="GET">#{body}</YAMAHA_AV>| 
        log("GET Request: #{command.inspect}", :debug)
        request(command)
      end

      def put_request(body)
        command = %|<YAMAHA_AV cmd="PUT">#{body}</YAMAHA_AV>|
        log("POST Request: #{command.inspect}", :debug)
        request(command)
      end

      def element_on?(element)
        case element.text
        when "On" then true
        when "Off" then false
        else element.text
        end
      end

      def element_volume_value(element)
        element.text.to_f / 10.0
      end
    end
  end
end
