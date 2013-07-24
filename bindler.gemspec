# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bindler/version'

Gem::Specification.new do |spec|
  spec.name          = "bindler"
  spec.version       = Bindler::VERSION
  spec.authors       = ["Fabio Rehm"]
  spec.email         = ["fgrehm@gmail.com"]
  spec.description   = %q{Dead easy Vagrant plugins management}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/fgrehm/bindler"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
