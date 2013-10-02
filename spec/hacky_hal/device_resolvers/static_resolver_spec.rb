require "spec_helper"
require "hacky_hal/device_resolvers/static_resolver"

describe HackyHAL::DeviceResolvers::StaticResolver do
  before(:all) do
    @resolver = described_class.new("http://device-host.local")
  end

  it "should return static host" do
    @resolver.uri.host.should == "device-host.local"
  end
end
