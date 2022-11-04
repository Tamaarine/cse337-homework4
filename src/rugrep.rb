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

def parse_regex(exp)
  # Return the regex object that represents the
  # pattern provided by the input exp.
  # exp must conform the specified string style, be surrounded
  # by double quotes.
  # Return nil if it cannot construct the regex object
  if not regex?(exp)
    return nil
  end
  
  begin
    return Regexp.new(exp[1...-1])
  rescue RegexpError
    return nil
  rescue
    # Catch all exception
    return nil
  end
end

def parseArgs(args)
  # Fill me
end

puts parseArgs(args)
