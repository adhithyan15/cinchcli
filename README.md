# Cinchcli
A very opinionated Ruby library for parsing CLI input. Extracted from my simple_configure project.

## What exactly is Cinchcli?
Cinchcli at its core is a command line parsing library combined with a little bit of magic. It takes a very declarative approach to building CLI tools. You describe your CLI tool in a JSON file. Cinchcli takes that JSON file and Ruby's `ARGV` as parameters and builds a scaffold for your CLI tool. It outputs a Hash of options parsed from the CLI input if the CLI input is valid or else it outputs a error message. It allows you to focus only on the core of your CLI tool instead of focusing on parsing CLI options.

## Installation
You can install Cinchcli by running
```
gem install cinchcli
```

## Documentation
To use Cinchcli in a project, first install it and then require the `cinchcli` module
```ruby
require 'cinchcli`
```

This should provide you access to the `Cinchcli` module. `Cinchcli` module has a `CinchCliBuilder` class that can be used to develop a CLI parser. `CinchCliBuilder` takes in two arguments. First one is a json file and the second one is the `ARGV` parameter from Ruby. Here is a simple CLI tool using this method

```ruby
#!/usr/bin/env ruby

# This code was taken from https://github.com/lsegal/yard/blob/master/bin/yard. The code is licensed under the MIT License.

# We do all this work just to find the proper load path
path = __FILE__
while File.symlink?(path)
  path = File.expand_path(File.readlink(path), File.dirname(path))
end
$:.unshift(File.join(File.dirname(File.expand_path(path)), '..', 'lib'))

require 'testcli'
require 'cinchcli'

parsed_cli_args = CinchCliBuilder.new("testcli.json",ARGV)
TestCli.run(parsed_cli_args)
```
