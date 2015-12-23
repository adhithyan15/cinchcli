require_relative "../../lib/cinchcli"

parsed_cli_args = CinchCliBuilder.new("../json_files/non_string_array_elements_in_description_field.json",ARGV)
