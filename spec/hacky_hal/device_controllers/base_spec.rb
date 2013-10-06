require "spec_helper"
require "hacky_hal/device_controllers/base"

describe HackyHAL::DeviceControllers::Base do
  it "should include Options" do
    described_class.ancestors.should include(HackyHAL::Options)
  end

  describe "#log" do
    it "should log to HackyHAL::Log with device name" do
      controller = described_class.new(name: "dummy device")
      HackyHAL::Log.instance.should_receive(:info).with("dummy device: dummy message")
      controller.log("dummy message", :info)
    end
  end
end
