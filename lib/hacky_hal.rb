require_relative "hacky_hal/registry"
require_relative "hacky_hal/log"

module HackyHAL
  DEVICE_CONTROLLERS_DIR = "hacky_hal/device_controllers"
  DEVICE_RESOLVERS_DIR = "hacky_hal/device_resolvers"

  controllers_dir = File.expand_path(DEVICE_CONTROLLERS_DIR, File.dirname(__FILE__))
  Dir["#{controllers_dir}/*"].each do |file|
    require_relative file
  end

  resolvers_dir = File.expand_path(DEVICE_RESOLVERS_DIR, File.dirname(__FILE__))
  Dir["#{resolvers_dir}/*"].each do |file|
    require_relative file
  end
end
