#!/usr/bin/env ruby
args = ARGF.argv
# args = ARGV

$usage = "USAGE: ruby rgrep.rb"
$error_regex = "Error: cannot parse regex"
$after_c = /\A(\-A_|\-\-after\-context=)(\d*)\z/
$before_c = /\A(\-B_|\-\-before\-context=)(\d*)\z/
$c = /\A(\-C_|\-\-context=)(\d*)\z/
$option_regexs = {
  "-A_NUM" => $after_c,
  "-B_NUM" => $before_c,
  "-C_NUM" => $c
}

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
  
def get_option_flags(args)
  # args: list of commandline argument. len(args) >= 2
  # Return false if any options is invalid or repeated options
  # Return a dictionary that map the simplified flag name to whether it exists or not
  # [ABC]_NUM also contain their respective arguments under _P extension
  
  flags = ["-v", "-c", "-l", "-L", "-o", "-F", "-A_NUM", "-B_NUM", "-C_NUM"]
  options = {}
  flags.each {|ele| options[ele] = false}
  
  args.each do |arg|
    if arg[0..1] == "--" or arg[0] == "-"
      simplified_flag = valid_option?(arg)
      return false if not simplified_flag       # If any is invalid, false
      return false if options[simplified_flag]  # dup options, false

      # Append the arguments _P if exists
      case simplified_flag
      when "-A_NUM"
        options["#{simplified_flag}_P"] = ($option_regexs[simplified_flag].match(arg))[2].to_i
      when "-B_NUM"
        options["#{simplified_flag}_P"] = ($option_regexs[simplified_flag].match(arg))[2].to_i
      when "-C_NUM"
        options["#{simplified_flag}_P"] = ($option_regexs[simplified_flag].match(arg))[2].to_i
      end
      options[simplified_flag] = true
    end
  end
  options
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
