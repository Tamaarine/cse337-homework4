#!/usr/bin/env ruby
args = ARGF.argv
# args = ARGV

def regex_format?(exp)
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
  if not regex_format?(exp)
    return nil
  end
  
  begin
    return Regexp.new(exp[1...-1])
  rescue
    # Catch all exception
    return nil
  end
end

def continous_regex?(args)
  # This function verifies if all the regex arguments
  # conforms with the format specified.
  # Return true if it is, false otherwise.
  # First tries to find the first regex index using .find.
  # if result is nil, return false. Then if it is true, it checks two elements ahead
  # to check if there is any P, X, P args. And return false if it did. Then lastly ret true, if it didn't
  # Assumes args >= 2, is checked in main
  
  first_regex_pos = args.length.times.find {|i| regex_format?(args[i])}

  if not first_regex_pos
    return false
  end
  
  (first_regex_pos...(args.length - 2)).each do |i|
    if not regex_format?(args[i + 1]) and regex_format?(args[i + 2])
      return false
    end
  end
  return true
end

def parseArgs(args)
  # Fill me
end

puts parseArgs(args)
