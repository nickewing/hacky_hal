require "spec_helper"
require "hacky_hal/device_controllers/generic_serial_port"

describe HackyHAL::DeviceControllers::GenericSerialPort do
  before(:each) do
    @serial_port = double("serial port")
    @serial_port.stub(:read_timeout=)
    @serial_port.stub(:baud=)
    @serial_port.stub(:data_bits=)
    @serial_port.stub(:stop_bits=)
    @serial_port.stub(:parity=)
    @serial_port.stub(:flow_control=)

    @serial_device_path = "/dev/foo0"
    @generic_serial_port = described_class.new(serial_device_path: @serial_device_path)

    SerialPort.stub(:new).and_return(@serial_port)
  end

  describe "#write_command" do
    before(:each) do
      @serial_port.stub(:flush)
    end

    it "should write to the serial port" do
      @serial_port.should_receive(:write).with("foobar\r\n")
      @generic_serial_port.write_command("foobar")
    end

    it "should return true on successful run" do
      @serial_port.should_receive(:write)
      @generic_serial_port.write_command("foobar").should be_true
    end

    it "should retry after rescuing from an Errno::EIO" do
      @generic_serial_port.should_receive(:disconnect)

      retries = 0
      @serial_port.stub(:write) do
        if retries < HackyHAL::DeviceControllers::GenericSerialPort::MAX_READ_WRITE_RETRIES
          retries += 1
          raise Errno::EIO
        end
      end

      @generic_serial_port.write_command("foobar").should be_true
    end

    it "should raise Errno::EIO if retry failed" do
      @serial_port.stub(:write) { raise Errno::EIO }
      @serial_port.stub(:close)

      expect {
        @generic_serial_port.write_command("foobar")
      }.to raise_error(Errno::EIO)
    end

    it "should log debug message" do
      @serial_port.stub(:write)
      @generic_serial_port.should_receive(:log).with("Wrote: \"foobar\\r\\n\"", :debug)
      @generic_serial_port.write_command("foobar")
    end
  end

  describe "#read_command" do
    it "should return read string on successful run" do
      @serial_port.stub(:readline).and_return("a return string")
      @generic_serial_port.read_command.should == "a return string"
    end

    it "should set the serial port read timeout to given value" do
      @serial_port.stub(:readline)
      @serial_port.should_receive(:read_timeout=).with(12000)
      @generic_serial_port.read_command(12)
    end

    it "should call handle_error if error_response?(response) is true" do
      @serial_port.stub(:readline)
      @generic_serial_port.stub(:error_response?).and_return(true)
      @generic_serial_port.should_receive(:handle_error)
      @generic_serial_port.read_command
    end

    it "should rescue EOFError and return nil" do
      @serial_port.stub(:readline) { raise EOFError }
      @generic_serial_port.read_command.should be_nil
    end

    it "should rescue EOFError and log warn message" do
      @serial_port.stub(:readline) { raise EOFError }
      @generic_serial_port.should_receive(:log).with("Read EOFError", :warn)
      @generic_serial_port.read_command
    end

    it "should retry after rescuing from an Errno::EIO" do
      @generic_serial_port.should_receive(:disconnect)

      retries = 0
      @serial_port.stub(:readline) do
        if retries < HackyHAL::DeviceControllers::GenericSerialPort::MAX_READ_WRITE_RETRIES
          retries += 1
          raise Errno::EIO
        else
          "a return string"
        end
      end

      @generic_serial_port.read_command.should == "a return string"
    end

    it "should raise Errno::EIO if retry failed" do
      @serial_port.stub(:readline) { raise Errno::EIO }
      @serial_port.stub(:close)

      expect {
        @generic_serial_port.read_command
      }.to raise_error(Errno::EIO)
    end

    it "should log debug message" do
      @serial_port.stub(:readline).and_return("response")
      @generic_serial_port.should_receive(:log).with("Read: \"response\"", :debug)
      @generic_serial_port.read_command
    end
  end

  describe "#disconnect" do
    it "should close serial port if serial port is set" do
      @generic_serial_port.serial_port # make sure serial port is set
      @serial_port.should_receive(:close)
      @generic_serial_port.disconnect
    end

    it "should not attempt to close serial port if serial port is not set" do
      @generic_serial_port.stub(:serial_port).and_return(nil)
      @generic_serial_port.disconnect
    end

    it "should set serial_port to nil" do
      @generic_serial_port.serial_port # make sure serial port is set
      @serial_port.should_receive(:close)
      @generic_serial_port.disconnect
      SerialPort.should_receive(:new)
      @generic_serial_port.serial_port
    end
  end

  describe "#serial_port" do
    it "should create new SerialPort" do
      SerialPort.should_receive(:new).with(@serial_device_path).and_return(@serial_port)
      @generic_serial_port.stub(:serial_options).and_return(
        baud_rate: 50,
        data_bits: 5,
        stop_bits: 2,
        parity: SerialPort::EVEN,
        flow_control: SerialPort::HARD
      )
      @serial_port.should_receive(:baud=).with(50)
      @serial_port.should_receive(:data_bits=).with(5)
      @serial_port.should_receive(:stop_bits=).with(2)
      @serial_port.should_receive(:parity=).with(SerialPort::EVEN)
      @serial_port.should_receive(:flow_control=).with(SerialPort::HARD)

      @generic_serial_port.serial_port.should == @serial_port
    end
  end
end
