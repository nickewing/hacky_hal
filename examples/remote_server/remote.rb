require "hacky_hal/log"
require "hacky_hal/device_controllers/roku"
require "hacky_hal/device_controllers/epson_projector"
require "hacky_hal/device_controllers/io_gear_avior_hdmi_switch"
require "hacky_hal/device_controllers/yamaha_av_receiver"
require "hacky_hal/device_controllers/osx_computer"
require "hacky_hal/device_controllers/linux_computer"
require "hacky_hal/device_resolvers/ssdp_resolver"

class Remote

  DEVICES = {
    projector: {
      type: "EpsonProjector",
      serial_device_path:
        "/dev/serial/by-id/usb-FTDI_USB_Serial_Converter_FTDW9VXM-if00-port0",
      model: "HC8350",
      av_receiver_output: "OUT_1"
    },
    av_receiver: {
      type: "YamahaAvReceiver",
      device_resolver: HackyHAL::DeviceResolvers::SsdpResolver.new(
        "upnp:rootdevice",
        "uuid:5f9ec1b3-ed59-1900-4530-00a0de90e681::upnp:rootdevice"
      ),
      default_input: "AV3"
    },
    roku: {
      type: "Roku",
      device_resolver: HackyHAL::DeviceResolvers::SsdpResolver.new(
        "upnp:rootdevice",
        "uuid:31474d33-3548-5b76-0000-050199040000:upnp:rootdevice"
      ),
      av_receiver_input: "AV1"
    },
    pc: {
      type: "LinuxComputer",
      host: "charles",
      user: "nick",
      av_receiver_input: "AV2",
      secondary_monitor_switch_input: 1
    },
    laptop: {
      type: "OsxComputer",
      host: "nick-aa-mbp",
      user: "nick",
      av_receiver_input: "AV3",
      secondary_monitor_switch_input: 2
    },
    secondary_monitor_switch: {
      type: "IoGearAviorHdmiSwitch",
      serial_device_path:
        "/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A101E4FV-if00-port0",
      unused_input: 4
    },
    primary_monitor: {
      type: "Base",
      av_receiver_output: "OUT_2"
    },
    secondary_monitor: {
      type: "Base"
    }
  }

  attr_reader :devices

  def initialize
    UPnP.log = false

    @devices = {}
    DEVICES.each do |name, config|
      config = config.dup
      type = config.delete(:type)
      config[:name] = name
      @devices[name] = HackyHAL::DeviceControllers.const_get(type).new(config)
    end
  end

  def set_input_output(options)
    avr_input = options["av_receiver_input"]
    avr_output = options["av_receiver_output"].split(",")
    switch_input = options["secondary_monitor_switch_input"].to_i

    avr_projector_output = avr_output.include?(devices[:projector][:av_receiver_output])
    avr_monitor_output = avr_output.include?(devices[:primary_monitor][:av_receiver_output])

    setup_av_reciever(avr_input)
    devices[:av_receiver].set_hdmi_output("OUT_1", avr_projector_output)
    devices[:av_receiver].set_hdmi_output("OUT_2", avr_monitor_output)

    devices[:secondary_monitor_switch].input = switch_input

    # TODO: Possibly clean this up by getting the list of available audio
    # outputs
    if avr_input == devices[:laptop][:av_receiver_input]
      if avr_projector_output
        set_laptop_audio_output_device("EPSON PJ")
      else
        set_laptop_audio_output_device("DELL 2408WFP")
      end
    else
      set_laptop_audio_output_device("Internal Speakers")
    end

    if avr_input == devices[:laptop][:av_receiver_input] &&
        switch_input == devices[:laptop][:secondary_monitor_switch_input]
      unmirror_laptop_screens
    else
      mirror_laptop_screens
    end

    if avr_input == devices[:pc][:av_receiver_input] &&
        switch_input == devices[:pc][:secondary_monitor_switch_input]
      unmirror_pc_screens
    else
      mirror_pc_screens
    end

    reset_pc_screens
  end

  def toggle_av_receiver_power
    HackyHAL::Log.debug(devices[:av_receiver].on)
    devices[:av_receiver].on = !devices[:av_receiver].on
  end

  def toggle_projector_power
    devices[:projector].on = !devices[:projector].on
  end

  def increase_volume(options)
    devices[:av_receiver].volume += options["amount"].to_i || 1
  end

  def mute
    devices[:av_receiver].mute = !devices[:av_receiver].mute
  end

  def rain
    devices[:laptop].exec("open 'http://rain.simplynoise.com'")
    set_laptop_audio_output_device("RX-A1020 90E681")

    devices[:av_receiver].set_hdmi_output("OUT_1", false)
    devices[:av_receiver].set_hdmi_output("OUT_2", false)

    devices[:secondary_monitor_switch].input =
      devices[:secondary_monitor_switch][:unused_input]

    devices[:projector].on = false
  end

  def mirror_pc_screens
    devices[:pc].mirror_screens("HDMI-0", "DVI-D-0")
  end

  def unmirror_pc_screens
    devices[:pc].set_screen_position("DVI-D-0", "HDMI-0", :left)
  end

  def reset_pc_screens
    devices[:pc].reset_display_settings("HDMI-0")
  end

  def mirror_laptop_screens
    devices[:laptop].mirror_screens
  end

  def unmirror_laptop_screens
    devices[:laptop].unmirror_screens
  end

  def set_laptop_audio_output_device(name)
    devices[:laptop].set_audio_output_device(name)
  end

  def disconnect
    devices[:projector].disconnect
    devices[:laptop].disconnect
    devices[:pc].disconnect
  end

  def projector_lamp_hours
    devices[:projector].lamp_hours
  end

  private

  def setup_av_reciever(input = AV_RECEIVER_DEFAULT_INPUT)
    devices[:av_receiver].input = input
    devices[:av_receiver].on = true
    devices[:av_receiver].mute = false
    # devices[:av_receiver].volume = -30.0
  end
end
