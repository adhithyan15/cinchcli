require_relative 'error'
require 'json'
require 'set'

##
# CinchCliBuilder class is the interface to the features provided by the
# cinchcli library. It provides the following features out of the box
# * Automatically generated tool help message
# * Automatically generated help messages for every command
# * Automatic type checking for each CLI input
# * Automatically generated error messages for each invalid CLI input
# * Default values for CLI commands
# * Fuzzy search for possibly misspelled commands
# * Automatic tab autocompletion support for commands
#
# The code is written verbosely on purpose to help readers understand
# the code much more easily. The code below follows the design
# document very closely. So please consult the design document at
# https://github.com/adhithyan15/cinchcli/wiki/Design-Doc if you have
# any questions
# @author Adhithya Rajasekaran

class CinchCliBuilder
  ##
  # initialize method creates a new CinchCliBuilder object and parses the ARGV
  # If the input JSON file is not valid, then it raises one of several possible errors.
  # @param tool_specification_file [String] name of the JSON file containing the tool specification
  # @param input_argv [String] Ruby's ARGV object

  def initialize(tool_specification_file, input_argv)
    verified_argv = verify_argv(input_argv)
    @argv = verified_argv
    parsed_json_file = parse_json_file(tool_specification_file)
    verified_json_specs = verify_json_file(parsed_json_file)
    @input_tool_specifications = verified_json_specs
    @parsed_argv = build_output()
  end

  ##
  # parse method returns the output Hash containing the parsed CLI input
  # @return [Hash] An output Hash containing the parsed CLI inputs
  def parse
    return @parsed_argv
  end

  private

  # Parses the provided JSON file and outputs a Hash containing provided specifications
  # of the CLI tool
  # @param input_file_name [String] name of the JSON file to be read
  # @return [Hash] contents of the JSON file as a Hash
  def parse_json_file(input_file_name)
    file = ""
    json_output = ""

    # First check to see if file name is null
    if input_file_name == nil
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: The JSON file name you have specified is null."
      error_message += " Please make sure that you have provided a correct path to a JSON file before proceeding.\n"
      error_message += user_note
      raise JSONFileNameNullError, error_message
    end

    # Second check to see if the file name is a string
    unless input_file_name.is_a?(String)
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: The JSON file name you have specified is not a String."
      error_message += " Please make sure that you have provided a valid String as an input for the JSON file name.\n"
      error_message += user_note
      raise JSONFileNameNotStringError, error_message
    end

    # Third check to see if the file name is empty
    if input_file_name == ""
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: The JSON file name you have specified is empty."
      error_message += " Please make sure that you have provided a correct path to a JSON file before proceeding.\n"
      error_message += user_note
      raise JSONFileNameEmptyError, error_message
    end

    # Fourth check to see if the file exists
    unless File.exist?(input_file_name)
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: The JSON file you specified doesn't seem to exist."
      error_message += " Please make sure that you have provided a correct path to a JSON file before proceeding.\n"
      error_message += user_note
      raise JSONFileNonExistantError, error_message
    end

    begin
      file = File.read(input_file_name)
    rescue
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: The JSON file you specified is not accessible."
      error_message += " This might be due to access control/previlege issues or the file might be corrupted!"
      error_message += " Please make sure that you provide an accessible JSON file before proceeding.\n"
      error_message += user_note
      raise InAccessibleJSONFileError, error_message
    end

    begin
      json_output = JSON.parse(file)
    rescue
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: The JSON file you specified couldn't be parsed."
      error_message += " Please make sure that you provide a parsable JSON file before proceeding.\n"
      error_message += user_note
      raise UnParsableJSONFileError, error_message
    end

    return json_output
  end

  # Verifies that the given argv is not null
  def verify_argv(input_argv)
    if input_argv == nil
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: The ARGV you passed in is null."
      error_message += " Please make sure that you are passing in an actual ARGV object into the CinchCliBuilder constructor.\n"
      error_message += user_note
      raise NullARGVError, error_message
    end

    return input_argv
  end

  # Verifies whether the required keys are present in the provided specifications
  # hash and makes sure that the optional keys meet conditions imposed by the Cinchcli
  # specifications
  # @param input_specifications_hash [Hash] The parsed JSON tool specifications in a Hash format
  # @return [Hash] The verified specifications Hash
  def verify_json_file(input_specifications_hash)
    # First check to see if the specifications hash is empty
    if input_specifications_hash == {}
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: The JSON file you specified doesn't have any valid specifications fields."
      error_message += " Please make sure that your JSON specifications file you specified is not empty.\n"
      error_message += user_note
      raise EmptyJSONSpecsFileError, error_message
    end

    # The following will be errors for the name field
    # First check to see if the name field is present
    # name field is a required field (design doc)
    if input_specifications_hash["name"].nil?
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file doesn't specify a name field."
      error_message += " name field is a required field and without that field Cinchcli cannot produce help and error messages."
      error_message += " Please make sure that your JSON specifications file has a name field.\n"
      error_message += user_note
      raise NoNameFieldInJSONSpecsFileError, error_message
    end

    # Second check to see if the name field provided is a string
    # name field should be a string (design doc)
    unless input_specifications_hash["name"].is_a?(String)
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file specifies a non String value of #{input_specifications_hash["name"]} as the value for the name field"
      error_message += " But the name field only takes a String value."
      error_message += " Please make sure that you are providing a String value as input to the name field before proceeding!\n"
      error_message += user_note
      raise NameFieldInJSONSpecsFileNotStringError, error_message
    end

    # Third check to see if the name field is an empty string
    # name field should be of length > 0
    if input_specifications_hash["name"].strip.eql?("")
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file specifies an empty string for the name field"
      error_message += " But the name field only takes a String value that is of non zero length and made up entirely of non space characters."
      error_message += " Please make sure that you are providing a non empty String for the name field\n"
      error_message += user_note
      raise NameFieldInJSONSpecsFileHasEmptyStringError, error_message
    end

    # Fourth check to see if the name field's value is made up of multiple words
    # The name of a CLI tool cannot be made up of multiple words with spaces in between
    # If you need a CLI tool name that is made of multiple words, consider hyphenating them.
    if input_specifications_hash["name"].lstrip.rstrip.split.count > 1
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file specifies String for the name field that has multiple words with spaces in between."
      error_message += " But the name field only takes a String value that is made up of a single word."
      error_message += " Please make sure that you are providing a single word as the input to the name field."
      error_message += " If you need a CLI tool name with multiple words, consider hyphenating them.\n"
      error_message += user_note
      raise NameFieldInJSONSpecsFileHasSpacesInBetweenError, error_message
    end

    # Automatically truncate the spaces in the front and rear of the String
    # for name field
    input_specifications_hash["name"] = input_specifications_hash["name"].lstrip.rstrip

    # Automatically downcase the name for unix convention reasons
    input_specifications_hash["name"] = input_specifications_hash["name"].downcase

    # The next set of checks will be for the description field
    # First check to see if the description field is present
    # description field is a required field (design doc)
    if input_specifications_hash["description"].nil?
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file doesn't specify a description field."
      error_message += " description field is a required field and without that field Cinchcli cannot produce help messages."
      error_message += " Please make sure that your JSON specifications file has a description field.\n"
      error_message += user_note
      raise NoDescriptionFieldInJSONSpecsFileError, error_message
    end

    # description field is slightly different from the name field in that
    # the type can be either a String or an Array of Strings. The Array of
    # Strings is to accomodate longer multiline descriptions. So two different
    # type checks are required.
    # Second check is to see if the provided description field matches either
    # a String or an Array
    unless input_specifications_hash["description"].is_a?(String) or input_specifications_hash["description"].is_a?(Array)
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file specifies a non String or Array value of #{input_specifications_hash["description"]} as the value for the description field."
      error_message += " But the description field only takes a String or an Array of Strings as value"
      error_message += " Please make sure that you are providing a String or an Array of Strings as input to the description field before proceeding!\n"
      error_message += user_note
      raise DescriptionFieldInJSONSpecsFileNotStringOrArrayOfStringsError, error_message
    end

    # If the description field is a String, then only one further check needs to be carried out
    # This check is to see if the description field value is a non empty String
    # description field has to be of length > 0 (design doc)
    if input_specifications_hash["description"].is_a?(String)
      if input_specifications_hash["description"].strip.eql?("")
        user_note = "User Note: The tool is not currently functional. Please contact the developer!"
        error_message = "Developer Note: Your JSON tool specifications file specifies an empty string for the description field."
        error_message += " But the description field only takes a String value that is of non zero length and made up entirely of non space characters."
        error_message += " Please make sure that you are providing a non empty String for the description field\n"
        error_message += user_note
        raise DescriptionFieldInJSONSpecsFileHasEmptyStringError, error_message
      end
    end

    # If the description field is an Array, then two checks need to be carried out
    # First check is to see if the description field array is not empty
    if input_specifications_hash["description"].is_a?(Array)
      if input_specifications_hash["description"].length == 0
        user_note = "User Note: The tool is not currently functional. Please contact the developer!"
        error_message = "Developer Note: Your JSON tool specifications file specifies an empty Array for the description field."
        error_message += " But the description field only takes an Array value that is of non zero length and made up entirely of Strings."
        error_message += " Please make sure that you are providing a non empty Array for the description field\n"
        error_message += user_note
        raise DescriptionFieldInJSONSpecsFileHasEmptyArrayError, error_message
      end
    end

    # Second check is to see if all the elements of the description field array are Strings
    if input_specifications_hash["description"].is_a?(Array)
      unless verify_array_of_strings(input_specifications_hash["description"]) == true
        user_note = "User Note: The tool is not currently functional. Please contact the developer!"
        error_message = "Developer Note: Your JSON tool specifications file specifies an Array for the description field which contains non String elements."
        error_message += " But the description field only takes an Array that is entirely made up Strings."
        error_message += " Please make sure that you are providing an Array of Strings for the description field\n"
        error_message += user_note
        raise DescriptionFieldInJSONSpecsFileHasArrayWithNonStringElementsError, error_message
      end
    end

    # Automatically combine the elements of the Array of Strings to form a single large String
    if input_specifications_hash["description"].is_a?(Array)
      input_specifications_hash["description"] = input_specifications_hash["description"].join()
    end

    # The next set of checks will be for the version field
    # version field is an another required field (design doc)
    # So first check would be check if the version field is present
    if input_specifications_hash["version"].nil?
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file doesn't specify a version field."
      error_message += " version field is a required field and without that field Cinchcli cannot produce version help message."
      error_message += " Please make sure that your JSON specifications file has a version field.\n"
      error_message += user_note
      raise NoVersionFieldInJSONSpecsFileError, error_message
    end

    # version field must have a String value (design doc)
    # So, second check is to see if the version field has a String value
    unless input_specifications_hash["version"].is_a?(String)
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file specifies a non String value of #{input_specifications_hash["version"]} as the value for the version field"
      error_message += " But the version field only takes a String value."
      error_message += " Please make sure that you are providing a String value as input to the version field before proceeding!\n"
      error_message += user_note
      raise VersionFieldInJSONSpecsFileNotStringError, error_message
    end

    # Next check is to see if the version field is an empty string
    # version field should be of length > 0 (design doc)
    if input_specifications_hash["version"].strip.eql?("")
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file specifies an empty string for the version field"
      error_message += " But the version field only takes a String value that is of non zero length and made up entirely of non space characters."
      error_message += " Please make sure that you are providing a non empty String for the version field\n"
      error_message += user_note
      raise VersionFieldInJSONSpecsFileHasEmptyStringError, error_message
    end

    # Finally check some optional fields to see whether they are present by any chance
    # default_help_messages_on takes only a Boolean field. So let us check that.
    unless input_specifications_hash["default_help_messages_on"].nil?
      unless [true,false].include?(input_specifications_hash["default_help_messages_on"])
        user_note = "User Note: The tool is not currently functional. Please contact the developer!"
        error_message = "Developer Note: Your JSON tool specifications file specifies a non Boolean value for the default_help_messages_on field."
        error_message += " default_help_messages_on field takes only a Boolean value."
        error_message += " Please make sure that your JSON specifications file has a Boolean value for the default_help_messages_on.\n"
        error_message += user_note
        raise DefaultHelpMessagesOnFieldInJSONSpecsFileHasNonBooleanValueError, error_message
      end
    end

    unless input_specifications_hash["default_version_messages_on"].nil?
      unless [true,false].include?(input_specifications_hash["default_version_messages_on"])
        user_note = "User Note: The tool is not currently functional. Please contact the developer!"
        error_message = "Developer Note: Your JSON tool specifications file specifies a non Boolean value for the default_version_messages_on field."
        error_message += " default_version_messages_on field takes only a Boolean value."
        error_message += " Please make sure that your JSON specifications file has a Boolean value for the default_version_messages_on.\n"
        error_message += user_note
        raise DefaultVersionMessagesOnFieldInJSONSpecsFileHasNonBooleanValueError, error_message
      end
    end

    unless input_specifications_hash["commands"].nil?
      unless input_specifications_hash["commands"].is_a?(Array)
        user_note = "User Note: The tool is not currently functional. Please contact the developer!"
        error_message = "Developer Note: Your JSON tool specifications file specifies a non Array value for the commands field."
        error_message += " commands field takes only a Array value."
        error_message += " Please make sure that your JSON specifications file has a Array value for the commands field.\n"
        error_message += user_note
        raise CommandsFieldInJSONSpecsFileHasNonArrayValueError, error_message
      end
    end

    unless input_specifications_hash["commands"].nil?
      unless check_for_empty_objects(input_specifications_hash["commands"])
        user_note = "User Note: The tool is not currently functional. Please contact the developer!"
        error_message = "Developer Note: Your JSON tool specifications file specifies an Array value for the commands field that has at least one empty command object."
        error_message += " Only non-empty command objects are allowed. Either remove the empty command object or fill it up with acceptable fields."
        error_message += " Please fix this issue before proceeding!\n"
        error_message += user_note
        raise CommandsFieldInJSONSpecsFileHasEmptyCommandObjectsError, error_message
      end
    end

    unless input_specifications_hash["commands"].nil?
      commands_verified, custom_error_message = verify_command_objects(input_specifications_hash["commands"])
      unless commands_verified
        user_note = "User Note: The tool is not currently functional. Please contact the developer!"
        error_message = "Developer Note: Your JSON tool specifications file specifies an Array value for the commands field that has at least one invalid command object."
        #error_message += " Valid fields for the command object can be found at https://github.com/adhithyan15/cinchcli/wiki/Design-Doc."
        error_message += custom_error_message
        error_message += " Please fix this issue before proceeding!\n"
        error_message += user_note
        raise CommandsFieldInJSONSpecsFileHasInvalidCommandObjectsError, error_message
      end
    end



    return input_specifications_hash
  end

  ##
  # build_output method does one of four things.
  # 1. If the input is valid and meets the provided specifications, it builds an
  #    output hash with the parsed input that can be used by the developers through the
  #    generate_output_hash method.
  # 2. For invalid inputs, it builds and outputs an error message through the
  #    generate_error_message method.
  # 3. If the input is for a help message, then it builds and outputs a help message
  #    through the generate_help_message method.
  # 4. If the input is for a version number message, then it builds and outputs a
  #    version number message.
  def build_output
    specifications = @input_tool_specifications
    # First Case
    # Empty ARGV indicating that no command line arguments or options were passed in
    if @argv.length == 0
      # In that case two subcases need to be handled
      # * if global_command is set to false, then the default help message will be the output
      # * if global_command is set to true, then the global_command will be set to true in
      #   the output hash. This case will be handled by the generate_output_hash method.
      if specifications["global_command"].nil?
        puts generate_help_message()
        abort()
      elsif specifications["global_command"] == true
        return generate_output_hash()
      end
    end

    # Second Case
    # ARGV of length 1. This means that one argument or option is passed along with the
    # global command.
    if @argv.length == 1
      # In that case five subcases need to be handled
      # * if ARGV[0] is one of --help, help or -h and default_help_messages_on is either nil or true
      #   then build and show the default help message.
      # * if ARGV[0] is one of --help, help or -h and default_help_messages_on is false,
      #   then pass ARGV[0] to generate_output_hash to set the corresponding ARGV[0] to true.
      # * if ARGV[0] is one of --version, version or -v and default_version_messages_on is either nil or true
      #   then build and show the default version message.
      # * if ARGV[0] is one of --version, version or -v and default_version_messages_on is false,
      #   then pass ARGV[0] to generate_output_hash to set the corresponding ARGV[0] to true.
      # * if ARGV[0] is anything else, then it is passed to generate_output_hash to set the
      #   corresponding ARGV[0] to true.

      help_commands = %w{--help -h help}
      version_commands = %w{--version -v version}
      build_hash = {}

      if help_commands.include?(@argv[0]) and (specifications["default_help_messages_on"].nil? or specifications["default_help_messages_on"])
        puts generate_help_message()
        abort()
      elsif help_commands.include?(@argv[0]) and specifications["default_help_messages_on"] == false
        build_hash[@argv[0]] = true
        return generate_output_hash(build_hash)
      elsif version_commands.include?(@argv[0]) and (specifications["default_version_messages_on"].nil? or specifications["default_version_messages_on"])
        puts generate_version_message()
        abort()
      elsif version_commands.include?(@argv[0]) and specifications["default_version_messages_on"] == false
        build_hash[@argv[0]] = true
        return generate_output_hash(build_hash)
      else
        build_hash[@argv[0]] = true
        return generate_output_hash(build_hash)
      end

    end

  end

  ##
  # generate_output_hash method builds the output hash that will be used by the
  # developers to build out the CLI tool. It is essentially the parsed
  # output based on the tool specifications.
  def generate_output_hash(input_build_hash = {})
    # Get the Tool specifications to validate the input commands
    specifications = @input_tool_specifications

    # The following are passthrough commands for which command verification
    # is unnecessary.
    passthrough_commands = %w{--help -h help --version -v version}

    # The output hash will be built up from the provided input Hash
    # Each key will be verified to see if it is present in the specifications
    # or not. Multiple single hyphenated command will be split up and each
    # individual component will be checked against the specifications.
    output_hash = {}

    # If the input_build_hash is empty, that means that the global_command was called
    if input_build_hash == {}
      output_hash["global_command"] = true
    else
      # We have a large number of edge cases to consider here
      # First, we need to extract the keys from the input_argv Hash and
      # each individual key needs to be examined to see if it meets specifications
      input_keys = input_build_hash.keys

      # Next, we will extract the commands specified in the commands array in
      # the JSON specifications file. This will allow us to verify whether each
      # command or argument meets specifications.
      specified_commands = specifications["commands"]

      # If input_keys has a length of one, then it means that we have one
      # of the passthrough commands provided above or we have a custom command
      # or a custom single hyphenated combo command or an argument
      if input_keys.length == 1
        # Passthrough commands are the ones listed above like help, version
        if passthrough_commands.include?(input_keys[0])
          output_hash = input_build_hash
        elsif !specified_commands.nil? and specified_commands.include?(input_keys[0])

        else
          puts generate_error_message(input_keys[0])
          abort()
        end
      end
    end

    return output_hash
  end

  ##
  # generate_help_message method builds a very general or a very specific help
  # message returns it. The very general help message is the overall help
  # message that user receives when passing in -h, --help or help as a command.
  # The very specific help message is what is shown when the user
  # types command help x or command -h x or command --help x
  # @param command [String]  Input command from build_output method if any. command is an optional argument
  # @return [String]  Output help message
  def generate_help_message(command = "")
    specifications = @input_tool_specifications
    output_help_message = ""
    if command.eql?("")
      output_help_message += "usage: #{specifications["name"]}\n"
      output_help_message += "\n"
      output_help_message += "#{specifications["description"]}"
    end
    return output_help_message
  end

  ##
  # generate_error_message method builds an error message based on the invalid
  # input provided. It also provide a fuzzy searched closest match query
  # as a suggestion to the user
  # @param command [String]  Input command from the generate_output_hash method
  # @return [String]  Output error message for the input command
  def generate_error_message(command)
    specifications = @input_tool_specifications
    specified_commands = specifications["commands"]
    output_error_message = "#{specifications["name"]}: '#{command}' is not a #{specifications["name"]} command. See '#{specifications["name"]} --help'.\n"
    output_error_message += "\n"
    output_error_message += generate_fuzzy_search_recommendations(command)
    return output_error_message
  end

  ##
  # generate_fuzzy_search_recommendations method builds an output String
  # based on the input possibly misspelled command and the specified commands
  # in the JSON file
  # @param command [String] Input possibly misspelled command
  # @return [String] Output suggestions string
  def generate_fuzzy_search_recommendations(command)
    return ""
  end

  ##
  # generate_version_message method builds and returns a version number message
  # This message is shown for --version, -v, version commands
  def generate_version_message()
    specifications = @input_tool_specifications
    output_help_message = "#{specifications["name"]} version #{specifications["version"]}"
    return output_help_message
  end

  ##
  # verify_array_of_strings method is just a helper method to verify whether an
  # Array contains all Strings
  # @param input_array [Array] An input array consisting of anything practically
  # @return [Boolean]
  def verify_array_of_strings(input_array)
    string_checked_array = input_array.collect {|element| element.is_a?(String)}
    if string_checked_array.count(false) > 0
      return false
    else
      return true
    end
  end

  ##
  # check_for_empty_objects method checks the commands array to see if any of the
  # command objects inside them are empty. Empty objects are not allowed. So
  # if empty objects are found, then it will be an error
  # @param input_array [Array] An input array consisting of command objects
  # @return [Boolean] A boolean output verifying whether there are empty objects present inside the input array
  def check_for_empty_objects(input_array)
    input_array.each do |command_object|
      if command_object == {}
        return false
      end
    end

    return true
  end

  ##
  # verify_command_objects method is just a helper method to verify whether
  # the command object inside the provided commands array has all the required
  # fields to allow for successful parsing and production of error and command
  # specific help messages.
  # @param input_array [Array] An input array consisting of command objects
  # @return [Boolean] A boolean output verifying whether there are valid command objects present inside the input array
  def verify_command_objects(input_array)
    # The following provides a list of currently allowed keys. This list will
    # be adjusted between the gem releases. It is declared here once to
    # save memory.
    allowed_keys = %w{short-option long-option plain description global_command alias}
    command_descriptors = %w{short-option long-option plain}

    # We will declare three sets (one for short-option, long-option and plain)
    # and these sets will be used to verify the uniqueness of each of the
    # specified command descriptors.
    short_options = Set.new()
    long_options = Set.new()
    plain_commands = Set.new()

    # To produce detailed error messages, we will also use a Hash to store
    # the locations of the previously encountered short-options, long-options
    # and plain commands. The stored index value would be the index+1 of
    # the command object that they were encountered in.
    command_descriptor_locations = {}

    # There should be only one global_command in the entire JSON specifications
    # file. So a global Hash object will be used to keep track of its presence
    # and throw an error if there are multiple global_command fields in the file
    global_command_presence = {}
    global_command_presence["presence"] = false

    # The input_array has an array of ruby hashes containing each command object.
    # They will be iterated over and each will be checked for validity.
    input_array.each_with_index do |command_object, index|
      # They keys for each array are extracted. The keys of the arrays themselves
      # will be first checked. Then their values will be extracted and checked for
      # correctness as well.
      command_object_keys = command_object.keys

      # The keys of each command object can only contain keys that are allowed
      # according to the list provided at the top. Any other keys will make
      # it invalid.
      command_object_keys.each do |key|
        unless allowed_keys.include?(key)
          error_message = " The key #{key} provided in command object no:#{index+1} is invalid."
          error_message += " The list of valid keys can be found at https://github.com/adhithyan15/cinchcli/wiki/Design-Doc."
          return [false, error_message]
        end
      end

      # The specifications must specify at least two fields for all commands except
      # the global_command. One of the command descriptor like shorthand, longhand
      # or plain and the description of the command. If either the command descriptor
      # or the description is missing, then raise an error.
      if command_object_keys.length == 1
        if command_object_keys[0] != "global_command"
           if command_object_keys[0] == "description"
             error_message = " No valid command descriptors were found in command object no:#{index+1}. "
             error_message += " You need to specify at least one of these command descriptors for each command - #{command_descriptors}"
             return [false, error_message]
           else
             error_message = " description field missing for the command #{command_object[command_object_keys[0]]} in command object no:#{index+1}."
             return [false, error_message]
           end
        end
      end

      if command_object_keys.include?("short-option") or command_object_keys.include?("long-option") or command_object_keys.include?("plain") or command_object_keys.include?("global_command")
        if command_object_keys.include?("global_command")
          # global_command command object shouldn't contain anyother fields
          if command_object_keys.length > 1
            error_message = " You have specified a global_command field in command object no:#{index+1}."
            error_message += " You cannot use any other command descriptors or description field with the global_command field."
            return [false,error_message]
          end
        else
          # if it is not a global_command field, then it should contain a description field
          unless command_object_keys.include?("description")
            error_message = " You haven't specified a description field for command object no:#{index+1}."
            return [false,error_message]
          end
        end
      else
        error_message = " No valid command descriptors were found in command object no:#{index+1}. "
        error_message += " You need to specify at least one of these command descriptors for each command - #{command_descriptors}."
        return [false, error_message]
      end

      # The values of each of the keys need to be tested to make sure that they are valid
      # First we will make sure that global_command and command descriptors have correct
      # type of values.
      if command_object_keys.include?("global_command")
        # global_command only takes a Boolean value. So let us check that
        unless [true,false].include?(command_object["global_command"])
          error_message = " global_command field was specified in command object no:#{index+1}."
          error_message += " global_command field only takes in a Boolean value."
          error_message += " But a non Boolean value of #{command_object["global_command"]} has been specified."
          return [false, error_message]
        end
      # The rest of the command descriptors need String values
      elsif command_object_keys.include?("short-option")
        unless command_object["short-option"].is_a?(String)
          error_message = " short-option field was specified in command object no:#{index+1}."
          error_message += " short-option field only takes in a String value."
          error_message += " But a non String value of #{command_object["short-option"]} has been specified."
          return [false, error_message]
        end
      elsif command_object_keys.include?("long-option")
        unless command_object["long-option"].is_a?(String)
          error_message = " long-option field was specified in command object no:#{index+1}."
          error_message += " long-option field only takes in a String value."
          error_message += " But a non String value of #{command_object["long-option"]} has been specified."
          return [false, error_message]
        end
      end

      # Next description needs to be checked to make sure that it has the correct type of values
      if command_object_keys.include?("description")
        # we will check and see if the description field is a String or an Array of Strings
        if command_object["description"].is_a?(String) or command_object["description"].is_a?(Array)
          # If it is a String, then it should be non-empty
          if command_object["description"].is_a?(String)
            if command_object["description"].strip == ""
              error_message = " description field was specified in command object no:#{index+1}."
              error_message += " description field value needs to be a non empty String."
              error_message += " But an empty String has been specified for the description field."
              return [false, error_message]
            end
          end

          # If it is an Array, then it should be non empty and all of its contents must be Strings
          if command_object["description"].is_a?(Array)
            if command_object["description"].length == 0
              error_message = " description field was specified in command object no:#{index+1}."
              error_message += " description field value needs to be a non empty Array of Strings."
              error_message += " But an empty Array has been specified for the description field."
              return [false, error_message]
            elsif verify_array_of_strings(command_object["description"]) == false
              error_message = " description field was specified in command object no:#{index+1}."
              error_message += " description field value needs to be a non empty Array of Strings."
              error_message += " But the specified Array has for the description field has non String contents."
              return [false, error_message]
            end
          end
        else
          error_message = " description field was specified in command object no:#{index+1}."
          error_message += " description field only takes in a String or an Array of Strings as value."
          error_message += " But a non String/Array of Strings value of #{command_object["description"]} has been specified."
          return [false, error_message]
        end
      end

      # Before we proceed for the uniqueness check, let us quickly check to make sure that if
      # short-options are specified, then their length is equal to 1
      if command_object_keys.include?("short-option")
        if command_object["short-option"].length != 1
          error_message = " short-option field was specified in command object no:#{index+1} with a value of #{command_object["short-option"]}."
          error_message += " But short-option fields can only have Strings of length 1."
          error_message += " If you need longer short-options, use long-options or consider combining several short-options using the combine_with field."
          error_message += " You can learn more about the combine_with field at https://github.com/adhithyan15/cinchcli/wiki/Design-Doc#tool-specification"
          return [false, error_message]
        end
      end

      # global_command can only be specified once in a JSON specifications file. Let us
      # check that.
      if command_object_keys.include?("global_command")
        if global_command_presence["presence"] == false
          global_command_presence["presence"] = true
          global_command_presence["presence_index"] = index+1
        else
          error_message = " global_command field was specified in command object no:#{index+1}."
          error_message += " But another global_command field was previously specified in command object no:#{global_command_presence["presence_index"]}."
          error_message += " global_command field can only be used once in your JSON specifications file as duplicating that field doesn't make any sense."
          return [false, error_message]
        end
      end

      # Now we will start checking for the uniqueness of each of the values to the short-option
      # long-option and plain command descriptors.
      # First are the short-options
      if command_object_keys.include?("short-option")
        # The following line will handle the edge case when for some reason the user
        # specifies the same single character short-option, long-option and plain command
        # Such a specification is valid under the design docs. So we need to handle
        # that use case.
        correct_short_option = "-" + command_object["short-option"]
        if short_options.add?(correct_short_option).nil?
          error_message = " short-option field with value #{command_object["short-option"]} was specified in command object no:#{index+1}."
          error_message += " But another short-option field previously specified in command object no:#{command_descriptor_locations[correct_short_option]}"
          error_message += " has the exact same value #{command_object["short-option"]}."
          error_message += " Each short-option value needs to be unique. Redefining short-options are not allowed."
          return [false, error_message]
        else
          command_descriptor_locations[correct_short_option] = index+1
        end
      end

      # Next are the long-options
      if command_object_keys.include?("long-option")
        # The same justification for the following line as in the short-option case and also an
        # additional edge case where the same value has been specified for the long-option and
        # plain command
        correct_long_option = "--" + command_object["long-option"]
        if long_options.add?(correct_long_option).nil?
          error_message = " long-option field with value #{command_object["long-option"]} was specified in command object no:#{index+1}."
          error_message += " But another long-option field previously specified in command object no:#{command_descriptor_locations[correct_long_option]}"
          error_message += " has the exact same value #{command_object["long-option"]}."
          error_message += " Each long-option value needs to be unique. Redefining long-options are not allowed."
          return [false, error_message]
        else
          command_descriptor_locations[correct_long_option] = index+1
        end
      end

      # Finally the plain commands
      if command_object_keys.include?("plain")
        if plain_commands.add?(command_object["plain"]).nil?
          error_message = " plain field with value #{command_object["plain"]} was specified in command object no:#{index+1}."
          error_message += " But another plain field previously specified in command object no:#{command_descriptor_locations[command_object["plain"]]}"
          error_message += " has the exact same value #{command_object["plain"]}."
          error_message += " Each plain field value needs to be unique. Redefining plain field values are not allowed."
          return [false, error_message]
        else
          command_descriptor_locations[command_object["plain"]] = index+1
        end
      end

    end
    return true
  end

  ##
  # process_commands_field method processes the commands field in the input specifications file
  # and add several keys to the input_specifications hash to make it easy for the parser to
  # parse and process the fields.
end
