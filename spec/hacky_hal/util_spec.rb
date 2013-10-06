require "spec_helper"
require "hacky_hal/util"

module DummyModule
  class DummyClass
  end
end

describe HackyHAL::Util do
  describe ".object_from_hash" do
    it "should require type" do
      expect { described_class.object_from_hash({foo: 1}, DummyModule) }.to raise_error(ArgumentError)
    end

    it "should return instance of built class" do
      dummy_instance = double("dummy instance")
      DummyModule::DummyClass.should_receive(:new).with(foo: 1).and_return(dummy_instance)
      described_class.object_from_hash({type: 'DummyClass', foo: 1}, DummyModule).should == dummy_instance
    end
  end

  describe ".symbolize_keys_deep" do
    it "should symbolize hash keys" do
      described_class.symbolize_keys_deep("a" => 1, :b => {"c" => 2}).should == {a: 1, b: {c: 2}}
    end
  end
end
