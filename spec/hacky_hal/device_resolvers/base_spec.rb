require "spec_helper"
require "hacky_hal/device_resolvers/base"

describe HackyHAL::DeviceResolvers::Base do
  it "should include Options" do
    described_class.ancestors.should include(HackyHAL::Options)
  end
end
