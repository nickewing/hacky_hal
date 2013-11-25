# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = "hacky_hal"
  gem.version = "0.2.0"

  gem.authors     = ["Nick Ewing"]
  gem.email       = ["nick@nickewing.net"]
  gem.description = "HackyHAL - Hacky Home Automation Library"
  gem.summary     = gem.description
  gem.homepage    = ""

  gem.add_dependency("upnp-nickewing", "~> 0.1.0")
  gem.add_dependency("serialport", "~> 1.1.0")
  gem.add_dependency("net-ssh", "~> 2.6.0")

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = ["lib"]
end
