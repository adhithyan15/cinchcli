require_relative "../../lib/cinchcli"

parsed_cli_args = CinchCliBuilder.new("../json_files/name_description_version.json",ARGV)
