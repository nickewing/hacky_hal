require "singleton"
require_relative "util"

module HackyHAL
  class Registry
    include Singleton

    attr_reader :devices

    def load_yaml_file(path)
      devices = YAML.load(File.read(File.expand_path(path)))
      devices = Util.symbolize_keys_deep(devices)

      @devices = {}
      devices.each do |name, config|
        config = config.dup
        config[:name] = name
        @devices[name] = Util.object_from_hash(config, HackyHAL::DeviceControllers)
      end
    end
  end
end
