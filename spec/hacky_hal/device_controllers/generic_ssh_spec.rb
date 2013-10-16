require "spec_helper"
require "hacky_hal/device_controllers/generic_ssh"

describe HackyHAL::DeviceControllers::GenericSsh do
  it "should require host option" do
    expect { described_class.new({}) }.
      to raise_error(ArgumentError,
                     "HackyHAL::DeviceControllers::GenericSsh must set host option.")
  end

  it "should require user option" do
    expect { described_class.new(host: "foo") }.
      to raise_error(ArgumentError,
                     "HackyHAL::DeviceControllers::GenericSsh must set user option.")
  end

  describe "with valid options" do
    before(:each) do
      @generic_ssh = described_class.new(
        host: "foo",
        user: "bar"
      )

      @ssh = double("ssh connection")
      @ssh.stub(:exec!).and_yield(nil, nil, "dummy output")
      @ssh.stub(:close)
      @ssh.stub(:closed?).and_return(false)
      Net::SSH.stub(:start).and_return(@ssh)
    end

    describe "#exec" do
      it "should pass command to ssh.exec!" do
        @ssh.should_receive(:exec!).with("dummy_command")
        @generic_ssh.exec("dummy_command")
      end

      it "should connect if not connected" do
        @generic_ssh.should_receive(:connected?).and_return(false)
        @generic_ssh.should_receive(:connect)
        @generic_ssh.stub(:ssh_exec)
        @generic_ssh.stub(:disconnect)
        @generic_ssh.exec("dummy_command")
      end

      it "should not connect if already connected" do
        @generic_ssh.should_receive(:connected?).and_return(true)
        @generic_ssh.should_not_receive(:connect)
        @generic_ssh.stub(:ssh_exec)
        @generic_ssh.stub(:disconnect)
        @generic_ssh.exec("dummy_command")
      end

      it "should join output from ssh.exec!" do
        @ssh.stub(:exec!).and_yield(nil, nil, "foo").and_yield(nil, nil, "bar")
        @generic_ssh.exec("dummy_command").should == "foobar"
      end

      it "should log debug message" do
        @generic_ssh.should_receive(:log).with("Command: \"dummy_command\"", :debug)
        @generic_ssh.should_receive(:log).with("Output: \"dummy output\"", :debug)
        @generic_ssh.exec("dummy_command")
      end

      describe "on command failure" do
        before(:each) do
          @generic_ssh.stub(:ssh_exec).and_raise(EOFError.new("foo"))
        end

        it "should log warn message" do
          @generic_ssh.should_receive(:log).with("Command: \"dummy_command\"", :debug).twice
          @generic_ssh.should_receive(:log).with("Command failed: EOFError - foo", :warn).twice
          @generic_ssh.should_receive(:log).with("Retrying last command", :warn).once
          @generic_ssh.exec("dummy_command")
        end

        it "should retry once after reconnecting" do
          @generic_ssh.should_receive(:disconnect).twice
          @generic_ssh.should_receive(:connect).twice
          @generic_ssh.exec("dummy_command")
        end
      end
    end

    describe "#connect" do
      it "should disconnect if already connected" do
        @generic_ssh.connect
        @generic_ssh.should_receive(:disconnect)
        @generic_ssh.connect
      end

      it "should open a new Net:SSH connection" do
        Net::SSH.should_receive(:start)
        @generic_ssh.connect
      end

      it "should log warn message on error" do
        Net::SSH.should_receive(:start).and_raise(SocketError.new("dummy message"))
        @generic_ssh.should_receive(:log).with("Failed to connect: SocketError - dummy message", :warn)
        @generic_ssh.connect
      end
    end

    describe "disconnect" do
      it "should close the ssh connection if connected" do
        @generic_ssh.connect
        @ssh.should_receive(:close)
        @generic_ssh.disconnect.should be_nil
      end

      it "should not close the ssh connection if not connected" do
        @generic_ssh.should_receive(:connected?).and_return(false)
        @ssh.should_not_receive(:close)
        @generic_ssh.disconnect.should be_nil
      end

      it "should return nil on Net::SSH::Disconnect" do
        @generic_ssh.connect
        @ssh.should_receive(:close).and_raise(Net::SSH::Disconnect)
        @generic_ssh.disconnect.should be_nil
      end

      it "should still disconnect on Net::SSH::Disconnect" do
        @generic_ssh.connect
        @ssh.should_receive(:close).and_raise(Net::SSH::Disconnect)
        @generic_ssh.disconnect
        @generic_ssh.connected?.should be_false
      end
    end

    describe "connect?" do
      it "should return true if connected" do
        @generic_ssh.connect
        @generic_ssh.connected?.should be_true
      end

      it "should return false if not connected" do
        @generic_ssh.connected?.should be_false
      end
    end
  end
end
