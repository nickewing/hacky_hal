require 'net/ssh'
require_relative "base"

module HackyHAL
  module DeviceControllers
    class GenericSsh < Base
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
        log("Command: #{command.inspect}", :debug)

        connect unless connected?

        out = nil

        begin
          out = ssh_exec(command)
          log("Output: #{out.inspect}", :debug)
        rescue => e
          log("Command failed: #{e.class.name} - #{e.message}", :warn)
          disconnect
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
        @ssh = nil
        nil
      rescue Net::SSH::Disconnect
        nil
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
