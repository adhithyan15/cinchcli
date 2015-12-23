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
class InAccessibleJSONFileError < StandardError
end

##
# An error for a unparsable JSON file
class UnParsableJSONFileError < StandardError
end

##
# An error for a null ARGV
class NullARGVError < StandardError
end

##
# An error for an empty JSON specifications file
class EmptyJSONSpecsFileError < StandardError
end

##
# An error for the absence of the name field in JSON specifications file
class NoNameFieldInJSONSpecsFileError < StandardError
end

##
# An error for a non string type provided as an input to the name field
class NameFieldInJSONSpecsFileNotStringError < StandardError
end

##
# An error for an empty string provided as an input to the name field
class NameFieldInJSONSpecsFileHasEmptyStringError < StandardError
end

##
# An error for a String containing multiple words for the name field
class NameFieldInJSONSpecsFileHasSpacesInBetweenError < StandardError
end

##
# An error for the absence of the description field in JSON specifications file
class NoDescriptionFieldInJSONSpecsFileError < StandardError
end

##
# An error for the presence of a non String or an Array of Strings for the
# description field in JSON specifications file
class DescriptionFieldInJSONSpecsFileNotStringOrArrayOfStringsError < StandardError
end

##
# An error for an empty string provided as an input to the description field
class DescriptionFieldInJSONSpecsFileHasEmptyStringError < StandardError
end

##
# An error for an empty array provided as an input to the description field
class DescriptionFieldInJSONSpecsFileHasEmptyArrayError < StandardError
end

##
# An error for an array with non String elements provided as an input to the description field
class DescriptionFieldInJSONSpecsFileHasArrayWithNonStringElementsError < StandardError
end
