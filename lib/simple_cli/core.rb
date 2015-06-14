require 'json'
module SimpleCli
  class SimpleCliBuilder
    def initialize(config_file)
      @allowable_arguments = config_file
    end

    private

    def parse_allowable_arguments(config_file)
      return JSON.parse(config_file)
    end

    def verify_config_file

    end
  end
end
