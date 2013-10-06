require "spec_helper"
require "hacky_hal/device_resolvers/static_uri"

describe HackyHAL::DeviceResolvers::StaticURI do
  it "should require uri option" do
    expect { described_class.new({}) }.to raise_error(
      ArgumentError,
      "#{described_class.name} must set uri option."
    )
  end

  it "should return static host" do
    resolver = described_class.new(uri: "http://device-host.local")
    resolver.uri.host.should == "device-host.local"
  end
end
