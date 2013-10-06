require "spec_helper"
require "hacky_hal/device_controllers/yamaha_av_receiver"

module HackyHAL
  module DeviceResolvers
    module Dummy
    end
  end
end

describe HackyHAL::DeviceControllers::YamahaAvReceiver do
  it "should require device_resolver" do
    expect { described_class.new({}) }.to raise_error(
      ArgumentError,
      "HackyHAL::DeviceControllers::YamahaAvReceiver must set device_resolver option."
    )
  end
  
  it "should resolve host through device resolver" do
    resolved_uri = double("resolved URI")
    resolved_uri.stub(:path=)
    resolved_uri.stub(:port=)
    device_resolver = double("device resolver")
    device_resolver.should_receive(:uri).and_return(resolved_uri)
    HackyHAL::DeviceResolvers::Dummy.should_receive(:new).with(foo: 1).and_return(device_resolver)
    controller = described_class.new(device_resolver: {type: 'Dummy', foo: 1})
    controller.host_uri.should == resolved_uri
  end
end
