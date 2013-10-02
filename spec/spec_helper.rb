require "bundler"
Bundler.require
require_relative "../lib/hacky_hal/log"

require "rspec/core"

RSpec.configure do |c|
  c.before(:suite) do
    HackyHAL::Log.instance.enabled = false
  end
end
