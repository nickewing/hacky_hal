require "hacky_hal"
require "yaml"

class Remote
  attr_reader :devices

  DEVICE_FILE = "./devices.yml"

  def initialize
    HackyHAL::Registry.instance.load_yaml_file(DEVICE_FILE)
  end

  def devices
    HackyHAL::Registry.instance.devices
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
