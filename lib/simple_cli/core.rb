require 'json'
require_relative 'error'

module SimpleCli
    class SimpleCliBuilder
      def initialize(config_file, argv = [])
        @config, @available_commands = parse_allowable_arguments(config_file)
        @raw_argv = argv
        @parsed_argv = parse_argv
      end

      private

      def error_message(command)
        return "Error: #{command} is not a valid command/option/argument!"
      end

      def build_help_message(config)
        message = "Usage: #{config["name"]}\n"
        message += "\n"
        message += "#{config["description"]}\n"
        message += "\n"
        return message
      end

      def version_message(config)
        message = "#{config["name"]} version #{config["version"]}\n\n"
        return message
      end

      def parse_allowable_arguments(config_file)
        user_note = "User Note: The developer made a mistake. So this tool is not currently functional!"
        if File.exist?(config_file)
          file = File.read(config_file)
        else
          raise JSONFileNonExistantError, "Developer Note: The JSON file you provided doesn't exist. Please provide a valid JSON file!\n" + user_note
        end

        begin
          json_data = JSON.parse(file)
        rescue
          raise UnParsableJSONError, "Developer Note: The JSON file you provided is not a valid JSON file. Please fix this issue!\n" + user_note
        end
        return verify_config_file(json_data)
      end

      def verify_config_file(config)
        user_note = "User Note: The developer made a mistake. So this tool is not currently functional!"

        if config == {}
          raise EmptyJSONError, "Developer Note: The JSON file you provided is empty. Please fix this issue!\n" + user_note
        end

        if config["name"].nil?
          raise NoNameError, "Developer Note: A CLI app requires a name. But no name has been provided. Please fix this issue!\n" + user_note
        elsif config["description"].nil?
          raise NoDescriptionError, "Developer Note: A CLI app requires a description. But no description has been provided. Please fix this issue!\n" + user_note
        elsif config["commands"].nil?
          raise NoCommandsError, "Developer Note: A CLI app requires a list of commands. But no commands have been provided. Please fix this issue! If your CLI tool doesn't take any commands, please use the no_command option inside the commands object to indicate that behavior\n" + user_note
        elsif config["commands"] == {}
          raise EmptyCommandsError, "Developer Note: A CLI app requires a list of commands. You have provided a commands object. But it is empty. Please fix this issue!\n" + user_note
        end

        available_commands = {}

        config["commands"].keys.each do |key|
          if key != "no_command"
            available_commands[key] = key
            command = config["commands"][key]
            unless command["alias"].nil?
              available_commands[command["alias"]] = key
            end
          end
        end

        return config, available_commands

      end

      def parse_argv
        parsed_argv = {}
        @raw_argv.each do |arg|
          case arg
          when "-h", "--help", "help"
            puts build_help_message(@config)
          when "-v", "--version", "version"
            puts version_message(@config)
          when !@available_commands[arg].nil?
            parsed_argv[available_commands[arg]] = true
          else
            puts "\n"
            puts error_message(arg)
            puts "\n"
            abort
          end
        end
        return parsed_argv
      end
  end
end
