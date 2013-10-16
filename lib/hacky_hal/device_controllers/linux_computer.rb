require_relative "generic_ssh"

module HackyHAL
  module DeviceControllers
    class LinuxComputer < GenericSsh
      def mirror_screens(source_screen, dest_screen)
        xrandr_command("--output #{dest_screen} --same-as #{source_screen}")
      end

      def set_screen_position(screen_1, screen_2, position)
        xrandr_command("--output #{screen_1} --#{position}-of #{screen_2}")
      end

      def reset_display_settings(screen)
        xrandr_command("--output #{screen} --auto")
      end

      private

      def xrandr_command(options)
        x_env_variables = [
          "CONSOLE=$(sudo fgconsole)",
          "SESSION=$(who -s | grep tty$CONSOLE | tr '()' ' ')",
          "XUSER=$(echo $SESSION | awk '{print $1}')",
          "DISPLAY=$(echo $SESSION | awk '{print $5}')",
          "XAUTHORITY=/home/$XUSER/.Xauthority",
          "export DISPLAY",
          "export XAUTHORITY"
        ].join("; ")

        command = "#{x_env_variables}; xrandr -d $DISPLAY #{options}"
        exec(command)
      end
    end
  end
end
