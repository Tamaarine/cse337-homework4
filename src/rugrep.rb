#!/usr/bin/env ruby
args = ARGF.argv
# args = ARGV

$usage = "USAGE: ruby rgrep.rb"
$error_regex = "Error: cannot parse regex"
$after_c = /\A(\-A_|\-\-after\-context=)(\d*)\z/
$before_c = /\A(\-B_|\-\-before\-context=)(\d*)\z/
$c = /\A(\-C_|\-\-context=)(\d*)\z/

def regex_format?(exp)
  # exp: A string
  # Return true if exp is a double quoted string
  exp[0] == '"' and exp[-1] == '"' and exp.length != 1
end

def parse_regex(exp)
  # exp: A string
  # Return the regex object that rep the pattern enclosed by the double quoted string
  # nil otherwise.
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

def valid_option?(option)
  # option: The option flag
  # Return the simplified version of the flag, --invert-match -> -v
  # nil if the option doesn't match
  case option
  when "-v", "--invert-match"
    return "-v"
  when "-c", "--count"
    return "-c"
  when "-l", "--files-with-matches"
    return "-l"
  when "-L", "--files-without-match"
    return "-L"
  when "-o", "--only-matching"
    return "-o"
  when "-F", "--fixed-strings"
    return "-F"
  end

  after_c = /\A(\-A_|\-\-after\-context=)(\d*)\z/
  before_c = /\A(\-B_|\-\-before\-context=)(\d*)\z/
  c = /\A(\-C_|\-\-context=)(\d*)\z/
  
  return after_c.match(option) if option =~ after_c
  return before_c.match(option) if option =~ before_c
  return c.match(option) if option =~ c
end

def continous_regex?(args)
  # args: The list of commandline argument. len(args) >= 2
  # Return true if there is at least one double
  # quoted regex exists in args. It further checks if there is
  # any P, X, P arguments, where P is regex, and X is either a option or file
  # False if the regex in args aren't continous or no regex exists.
  
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
