require_relative "../../lib/cinchcli"

parsed_cli_args = CinchCliBuilder.new("../json_files/non_string_name_field.json",ARGV)
