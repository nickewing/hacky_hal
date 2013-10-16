require 'net/ssh'
require_relative "base"

module HackyHAL
  module DeviceControllers
    class GenericSsh < Base
      MAX_COMMAND_RETRIES = 1

      attr_reader :host, :user, :ssh_options

      def initialize(options)
        super(options)

        ensure_option(:host)
        ensure_option(:user)

        @host = options[:host]
        @user = options[:user]
        @ssh_options = options[:ssh_options] || {}
      end

      def exec(command)
        out = nil
        retries = 0

        begin
          connect unless connected?
          log("Command: #{command.inspect}", :debug)
          out = ssh_exec(command)
          log("Output: #{out.inspect}", :debug)
        rescue Net::SSH::Disconnect, EOFError  => e
          log("Command failed: #{e.class.name} - #{e.message}", :warn)
          disconnect

          if retries < MAX_COMMAND_RETRIES
            log("Retrying last command", :warn)
            retries += 1
            retry
          end
        end

        out
      end

      def connect
        disconnect if @ssh
        @ssh = Net::SSH.start(host, user, ssh_options)
      rescue SocketError, Net::SSH::Exception, Errno::EHOSTUNREACH => e
        log("Failed to connect: #{e.class.name} - #{e.message}", :warn)
      end

      def connected?
        @ssh && !@ssh.closed?
      end

      def disconnect
        @ssh.close if connected?
      rescue Net::SSH::Disconnect
      ensure
        @ssh = nil
      end

      private

      def ssh_exec(command)
        out = []
        @ssh.exec!(command) do |channel, stream, data|
          out << data
        end
        out.join("")
      end
    end
  end
end
