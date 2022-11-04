#!/usr/bin/env ruby
args = ARGF.argv
# args = ARGV

def regex?(exp)
  # Returns true if the input string is a regex
  # specified by two quotes in front and the back
  # ex. \"[ab]pple\" is valid
  # ex. \" is not valid
  exp[0] == '"' and exp[-1] == '"' and exp.length != 1
end

def parseArgs(args)
  # Fill me
end

puts parseArgs(args)
