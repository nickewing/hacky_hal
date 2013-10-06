require "spec_helper"
require "hacky_hal/options"

class DummyClass
  include HackyHAL::Options
end

describe HackyHAL::Options do
  describe "#initialize" do
    it "should set options" do
      object = DummyClass.new(dummy_argument: "dummy value")
      object.options.should == {dummy_argument: "dummy value"}
    end
  end

  describe "#[]" do
    it "should return option values" do
      object = DummyClass.new(dummy_argument: "dummy value")
      object[:dummy_argument].should == "dummy value"
    end
  end
end
