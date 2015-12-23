require_relative "../../lib/cinchcli"

parsed_cli_args = CinchCliBuilder.new("../json_files/name_and_description.json",ARGV)
