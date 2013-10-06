require "spec_helper"
require "hacky_hal/device_resolvers/ssdp"

describe HackyHAL::DeviceResolvers::SSDP do
  it "should require usn option" do
    expect { described_class.new({}) }.to raise_error(
      ArgumentError,
      "#{described_class.name} must set usn option."
    )
  end

  it "should default to search for root devices" do
    resolver = described_class.new(usn: "dummy-usn")
    resolver.options[:search].should == "upnp:rootdevice"
  end

  describe "instance" do
    before(:each) do
      @resolver = described_class.new(search: "dummy-device-search", usn: "dummy-usn")
    end

    it "should return uri resolved via SSDP" do
      UPnP::SSDP.stub(:search).and_return([
        {location: "http://resolved-host/path", usn: "dummy-usn"}
      ])
      @resolver.uri.host.should == "resolved-host"
    end

    it "should raise SsdpUnresolvedDevice if no device found" do
      UPnP::SSDP.stub(:search).and_return([])
      expect { @resolver.uri }.to raise_error(HackyHAL::DeviceResolvers::SsdpUnresolvedDevice)
    end

    it "should return the host of device with given USN" do
      UPnP::SSDP.stub(:search).and_return([
        {location: "http://other-resolved-host/path", usn: "other-usn"},
        {location: "http://resolved-host/path", usn: "dummy-usn"}
      ])
      @resolver.uri.host.should == "resolved-host"
    end

    it "should raise SsdpUnresolvedDevice if device with request USN not found" do
      UPnP::SSDP.stub(:search).and_return([
        {location: "http://other-resolved-host/path", usn: "other-usn"}
      ])
      expect { @resolver.uri }.to raise_error(HackyHAL::DeviceResolvers::SsdpUnresolvedDevice)
    end
  end
end
