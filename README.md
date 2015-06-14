# simple_cli
A very opinionated Ruby library for parsing CLI input. Extracted from my simple_configure project.

## What exactly is simple_cli?
simple_cli at its core is a command line parsing library combined with a little bit of magic. It takes a very declarative approach to building CLI tools. You describe your CLI tool in a json file. simple_cli takes that json file and Ruby's `ARGV` as parameters and builds a scaffold for your CLI tool. It outputs a Hash of options parsed from the CLI input if the CLI input is valid or else it outputs a help message. It allows you to focus only on the core of your CLI tool instead of focusing on parsing CLI options. 

## Installation
You can install simple_cli by running
```
gem install simple_cli
```

## Documentation
To use simple_cli in a project, require the `simple_cli` module
```ruby
require 'simple_cli`
```
