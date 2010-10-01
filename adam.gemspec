lib = File.expand_path('../lib', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "adam"

Gem::Specification.new do |s|
  s.name          = "adam"
  s.version       = Adam::VERSION
  s.authors       = ["Johannes Gorset"]
  s.email         = "jgorset@gmail.com"
  s.homepage      = "http://github.com/frkt/adam"
  s.summary       = "Adam is a library for all things EVE"
  s.files         = Dir.glob("{config,db,lib}/**/*") + %w(README.md)
end
