$:.push File.expand_path("../lib", __FILE__)

require "adam/version"

Gem::Specification.new do |s|
  s.name                  = "adam"
  s.version               = Adam::VERSION
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = ">= 1.9"
  s.authors               = ["Johannes Gorset"]
  s.email                 = "jgorset@gmail.com"
  s.homepage              = "http://github.com/jgorset/adam"
  s.summary               = "Adam is a library for all things EVE"
  s.description           = "Adam is a library for all things EVE"
  
  s.files                 = Dir.glob("{lib}/**/*") + %w(README.md)
  s.require_paths         = ["lib"]
  
  s.add_dependency "activerecord"
  s.add_dependency "hpricot"
end
