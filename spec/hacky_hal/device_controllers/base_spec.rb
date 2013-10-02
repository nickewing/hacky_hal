require "spec_helper"
require "hacky_hal/device_controllers/base"

describe HackyHAL::DeviceControllers::Base do
  describe "#[]" do
    it "should return option values" do
      controller = described_class.new(dummy_argument: "dummy value")
      controller[:dummy_argument].should == "dummy value"
    end
  end

  describe "#log" do
    it "should log to HackyHAL::Log with device name" do
      controller = described_class.new(name: "dummy device")
      HackyHAL::Log.instance.should_receive(:info).with("dummy device: dummy message")
      controller.log("dummy message", :info)
    end
  end
end
