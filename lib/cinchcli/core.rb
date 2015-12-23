require_relative 'error'
require 'json'

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
  # @param tool_specification [String] name of the JSON file containing the tool specification
  # @param input_argv [String] Ruby's ARGV object

  def initialize(tool_specification_file, input_argv)
    verified_argv = verify_argv(input_argv)
    @argv = verified_argv
    parsed_json_file = parse_json_file(tool_specification_file)
    verified_json_specs = verify_json_file(parsed_json_file)
    @input_tool_specifications = verified_json_specs
    @parsed_argv = {}
  end

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
  def verify_json_file(input_specifications_hash)
    # First check to see if the specifications hash is empty
    if input_specifications_hash == {}
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: The JSON file you specified doesn't have any valid specifications fields."
      error_message += " Please make sure that your JSON specifications file you specified is not empty.\n"
      error_message += user_note
      raise EmptyJSONSpecsFileError, error_message
    end

    # Second check to see if the name field is present
    # name field is a required field (design doc)
    if input_specifications_hash["name"].nil?
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file doesn't specify a name field."
      error_message += " name field is a required field and without that field Cinchcli cannot produce help and error messages."
      error_message += " Please make sure that your JSON specifications file has a name field.\n"
      error_message += user_note
      raise NoNameFieldInJSONSpecsFileError, error_message
    end

    # Third check to see if the name field provided is a string
    # name field should be a string (design doc)
    unless input_specifications_hash["name"].is_a?(String)
      user_note = "User Note: The tool is not currently functional. Please contact the developer!"
      error_message = "Developer Note: Your JSON tool specifications file specifies a non String value of #{input_specifications_hash["name"]} as the value for the name field"
      error_message += " But the name field only takes a String value."
      error_message += " Please make sure that you are providing a String value as input to the name field before proceeding!\n"
      error_message += user_note
      raise NameFieldInJSONSpecsFileNotStringError, error_message
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
    puts @argv.inspect
  end

  ##
  # generate_output_hash method builds the output hash that will be used by the
  # developers to build out the CLI tool. It is essentially the parsed
  # output based on the tool specifications.
  def generate_output_hash

  end

end
