require 'open3'
require 'json'
require 'colorize'

puts "Testing Begins!"
puts "A lot of information will be printed out for debugging information!"
error_names_files = JSON.parse(File.read("error_messages.json"))
error_names = error_names_files.keys
test_count = error_names.length
checkmark = "Error Found! - " + "\u2713"
wrong = "Error Not Found! - " + "\u2718"

puts "\n"
puts "Environment Setup"
puts "Working directory needs to be changed around to execute the tests!"
puts "The current work directory is #{Dir.pwd}"
basedir = Dir.pwd
puts "Changing the directory to tool_files to load up all the test files!"
Dir.chdir "tool_files"
puts "The working directory should now be changed to tool_files"
if basedir+"/tool_files" == Dir.pwd
  puts "Yes, the working directory has been successfully changed!"
else
  puts "The working directory failed to change. So quitting!"
  abort
end

puts "\n"
puts "Counting the number of tests to be executed!"
puts "The total number of tests to be executed is #{test_count}"

puts "\n"
error_names.each do |error_name|
  puts "File Name: #{error_names_files[error_name]}"
  puts "Checking For Error: #{error_name}"
  stdout, stdeerr, status = Open3.capture3("ruby #{error_names_files[error_name]}")
  puts stdeerr
  if stdeerr.include?(error_name)
    puts checkmark.encode('utf-8').green
  else
    puts wrong.encode('utf-8').red
    abort
  end
  puts "\n"
end
