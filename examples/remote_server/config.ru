require "bundler"
Bundler.require
require "hacky_hal/log"

require File.expand_path("server", File.dirname(__FILE__))

use Rack::CommonLogger, HackyHAL::Log.instance

run Sinatra::Application
