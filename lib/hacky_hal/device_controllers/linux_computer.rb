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
          "export CONSOLE=`sudo fgconsole`",
          "export SESSION=`who -s | grep tty$CONSOLE | tr '()' ' '`",
          "export DISPLAY=`echo $SESSION | awk '{print $5}'`",
          "export XUSER=`echo $SESSION | awk '{print $1}'`",
          "export XAUTHORITY=/home/$XUSER/.Xauthority"
        ].join("; ")

        command = "#{x_env_variables}; xrandr -d $DISPLAY #{options}"
        exec(command)
      end
    end
  end
end
