# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinchcli/version'

Gem::Specification.new do |spec|
  spec.name          = "cinchcli"
  spec.version       = Cinchcli::VERSION
  spec.authors       = ["Adhithya Rajasekaran"]
  spec.email         = ["adhithyan15@gmail.com"]
  spec.summary       = %q{Building CLI tools is hard. Cinchcli is here to help!}
  spec.description   = %q{Cinchcli is a very opinionated but powerful toolkit for building CLI tools}
  spec.homepage      = "https://github.com/adhithyan15/cinchcli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
