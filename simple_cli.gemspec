# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_cli/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_cli"
  spec.version       = SimpleCli::VERSION
  spec.authors       = ["Adhithya Rajasekaran"]
  spec.email         = ["adhithyan15@gmail.com"]
  spec.summary       = %q{An opinionated Ruby library for building CLI tools}
  spec.description   = %q{Building CLI tools is really hard. This library should make it slightly easy to do them. It takes a declarative approach to building CLI tools. Please read the documentation to learn more~}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency 'json', '~> 1.8'
end
