# This file defines all the errors that you could possibly encounter
# during your development

##
# An error for a null JSON file
class JSONFileNameNullError < StandardError
end

##
# An error for a non string JSON file name
class JSONFileNameNotStringError < StandardError
end

##
# An error for an empty JSON file name
class JSONFileNameEmptyError < StandardError
end

##
# An error for a non existant JSON file
class JSONFileNonExistantError < StandardError
end

##
# An error for corrupted JSON file
# Only error without a test in test.rb as I am
# unable to find a way to corrupt any file manually
class JSONFileCorruptedError < StandardError
end

##
# An error for a unparsable JSON file
class UnParsableJSONFileError < StandardError
end

##
# An error for a null ARGV
class NullARGVError < StandardError
end
