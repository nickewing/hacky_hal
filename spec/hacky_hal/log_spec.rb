require "spec_helper"
require "hacky_hal/log"

describe HackyHAL::Log do
  before(:all) do
    @old_logger_state = HackyHAL::Log.instance.enabled
    HackyHAL::Log.instance.enabled = true
  end

  after(:all) do
    HackyHAL::Log.instance.enabled = @old_logger_state
  end

  it "should use custom formatter" do
    described_class.instance.formatter.should be_a(described_class::Formatter)
    described_class.instance.formatter.should_receive(:call)
    described_class.instance.info("foo")
  end

  describe "#write" do
    it "should alias to self.<<" do
      described_class.instance.should_receive(:<<).with("foo")
      described_class.instance.write("foo")
    end
  end
end
