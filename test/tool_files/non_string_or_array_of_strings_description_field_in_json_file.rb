require_relative "../../lib/cinchcli"

parsed_cli_args = CinchCliBuilder.new("../json_files/non_string_or_array_of_strings_description_field.json",ARGV)
