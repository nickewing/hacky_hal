require "spec_helper"
require "hacky_hal/registry"

describe HackyHAL::Registry do
  describe "#load_yaml_file" do
    before(:each) do
      @device_config = {
        "foo_device" => {
          "type" => "Base",
          "foo" => "bar"
        }
      }
      File.stub(:read)
      YAML.stub(:load).and_return(@device_config)
    end

    it "should load and initialize device controllers into registry" do
      described_class.instance.load_yaml_file("foo.yml")
      devices = described_class.instance.devices
      devices.length.should == 1
      devices[:foo_device].should be_instance_of(HackyHAL::DeviceControllers::Base)
    end

    it "should convert keys to symbols" do
      described_class.instance.load_yaml_file("foo.yml")
      devices = described_class.instance.devices
      devices[:foo_device][:foo].should == "bar"
    end
  end
end
