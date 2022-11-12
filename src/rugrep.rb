#!/usr/bin/env ruby
args = ARGF.argv
# args = ARGV

$usage = "USAGE: ruby rugrep.rb"
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

  return "-A_NUM" if option =~ $after_c
  return "-B_NUM" if option =~ $before_c
  return "-C_NUM" if option =~ $c
end

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

def sum_flags(option_flags)
  # option_flags: the dictionary from parseArgs. All are valid flags
  # return the number of true flags
  sum = 0
  option_flags.each {|key, value| sum += 1 if key[-2..] != "_P" and value }
  sum
end

def get_files(args)
  # args: The list of commandline argument.
  # return another array that consists of only the files
  args.filter {|arg| not regex_format?(arg) and not (arg[0..1] == "--" or arg[0] == "-")}
end

def get_regexs(args, script_ret)
  # args: The list of commandline argument.
  # script_ret: the string to append messages to
  # return another array that consists of the regex pattern objects
  # also return script_ret after is appended
  ret = []
  args.each do |arg|
    if regex_format?(arg)
      parsed = parse_regex(arg)
      if not parsed
        script_ret += "Error: cannot parse regex #{arg}\n"
      else
        ret.push(parsed)
      end
    end
  end
  return ret, script_ret
end

def open_files(files, script_ret)
  # files: list of files path
  # script_ret: the string to append messages to
  # return a hash of opened file objects. key = file_name, value = file object
  # also return script_ret after is appended
  ret = {}
  files.each do |file|
    begin
      raise StandardError.new if File.directory?(file)
      ret[file] = File.open(file)
    rescue
      script_ret += "Error: could not read file #{file}\n"
    end
  end
  return ret, script_ret
end

def before_context(matched_indices, spacing, all_lines, script_ret, filename)
  # matched_indices: list of indices that contained the regex match
  # spacing: how many lines before
  # all_lines: all of the lines of the file
  # script_ret: the string to append messages to
  # filename: the file we are operating on
  m_length = matched_indices.length
  m_length.times do |i|
    curr = matched_indices[i]
    final = curr - spacing < 0 ? 0 : curr - spacing
    
    ret = all_lines[final..curr].map {|line| filename == "" ? "#{ostrip(line)}\n" : "#{filename}: #{ostrip(line)}\n"}
    script_ret += ret.join("")
    script_ret += "--\n" if i != m_length - 1
  end
  script_ret
end

def after_context(matched_indices, spacing, all_lines, script_ret, filename)
  m_length = matched_indices.length
  l_length = all_lines.length
  m_length.times do |i|
    curr = matched_indices[i]
    final = curr + spacing >= l_length ? l_length - 1 : curr + spacing
    
    ret = all_lines[curr..final].map {|line| filename == "" ? "#{ostrip(line)}\n" : "#{filename}: #{ostrip(line)}\n"}
    script_ret += ret.join("")
    script_ret += "--\n" if i != m_length - 1
  end
  script_ret
end

def context(matched_indices, spacing, all_lines, script_ret, filename)
  m_length = matched_indices.length
  l_length = all_lines.length
  m_length.times do |i|
    curr = matched_indices[i]
    final_b = curr - spacing < 0 ? 0 : curr - spacing
    final_a = curr + spacing >= l_length ? l_length - 1 : curr + spacing
    
    ret = all_lines[final_b..final_a].map {|line| filename == "" ? "#{ostrip(line)}\n" : "#{filename}: #{ostrip(line)}\n"}
    script_ret += ret.join("")
    script_ret += "--\n" if i != m_length - 1
  end
  script_ret
end

def ostrip(input)
  # My own strip function
  ret = input[-1] == "\n" ? input[...-1] : input
end

def do_matching(files, regexs, script_ret, optional_flag, spacing=0)
  # files: Map of opened files object
  # regexs: List of regex objects
  # script_ret: the string to append messages to
  # Return script_ret the lines of files that matches regexs
  if files.length == 1 # No prefix needed
    key = files.keys[0]
    count = 0
    matched_indices = []
    files[key].each_with_index do |line, i|
      case optional_flag
      when "-v"
        ret = regexs.all? {|reg| line !~ reg}
        script_ret += "#{ostrip(line)}\n" if ret
      when "-c", "-l", "-L"
        ret = regexs.find {|reg| line =~ reg}
        count += 1 if ret
      when "-o"
        regexs.each do |reg|
          matches = line.scan(reg)
          matches.each {|match| script_ret += "#{match}\n"}
        end
      when "-F"
        ret = regexs.find {|reg| line.index(reg) != nil}
        script_ret += "#{ostrip(line)}\n" if ret
      when "-A_NUM", "-B_NUM", "-C_NUM"
        ret = regexs.find {|reg| line =~ reg}
        matched_indices.push(i) if ret
      else
        ret = regexs.find {|reg| line =~ reg}
        script_ret += "#{ostrip(line)}\n" if ret
      end
    end
    script_ret += "#{count}\n" if optional_flag == "-c"
    script_ret += "#{File.basename(files[key])}\n" if optional_flag == "-l" and count > 0
    script_ret += "#{File.basename(files[key])}\n" if optional_flag == "-L" and count == 0
    script_ret = after_context(matched_indices, spacing, IO.readlines(key), script_ret, "") if optional_flag == "-A_NUM"
    script_ret = before_context(matched_indices, spacing, IO.readlines(key), script_ret, "") if optional_flag == "-B_NUM"
    script_ret = context(matched_indices, spacing, IO.readlines(key), script_ret, "") if optional_flag == "-C_NUM"
    files[key].close
  else
    files.each do |file, file_o|
      count = 0
      matched_indices = []
      file_o.each_with_index do |line, i|
        case optional_flag
        when "-v"
          ret = regexs.all? {|reg| line !~ reg}
          script_ret += "#{file}: #{ostrip(line)}\n" if ret
        when "-c", "-l", "-L"
          ret = regexs.find {|reg| line =~ reg}
          count += 1 if ret
        when "-o"
          regexs.each do |reg|
            matches = line.scan(reg)
            matches.each {|match| script_ret += "#{file}: #{match}\n"}
          end
        when "-F"
          ret = regexs.find {|reg| line.index(reg) != nil}
          script_ret += "#{ostrip(line)}\n" if ret
        when "-A_NUM", "-B_NUM", "-C_NUM"
          ret = regexs.find {|reg| line =~ reg}
          matched_indices.push(i) if ret
        else
          ret = regexs.find {|reg| line =~ reg}
          script_ret += "#{file}: #{ostrip(line)}\n" if ret
        end
      end
      script_ret += "#{file}: #{count}\n" if optional_flag == "-c"
      script_ret += "#{File.basename(file_o)}\n" if optional_flag == "-l" and count > 0
      script_ret += "#{File.basename(file_o)}\n" if optional_flag == "-L" and count == 0
      script_ret = after_context(matched_indices, spacing, IO.readlines(file), script_ret, file) if optional_flag == "-A_NUM"
      script_ret = before_context(matched_indices, spacing, IO.readlines(file), script_ret, file) if optional_flag == "-B_NUM"
      script_ret = context(matched_indices, spacing, IO.readlines(file), script_ret, file) if optional_flag == "-C_NUM"
      file_o.close
    end
  end
  script_ret
end

def do_matching2(files, regexs, script_ret, optional_flag, spacing=0)
  if files.length == 1
    key = files.keys[0]
    count = 0
    files[key].each_with_index do |line, i|
      case optional_flag
      when "-cv"
        ret = regexs.all? {|reg| line !~ reg}
        count += 1 if ret
      when "-Fc"
        ret = regexs.find {|reg| line.index(reg) != nil}
        count += 1 if ret
      end
    end
    script_ret += "#{count}\n" if optional_flag == "-cv"
    script_ret += "#{count}\n" if optional_flag == "-Fc"
  else
    files.each do |file, file_o|
      count = 0
      matched_indices = []
      file_o.each_with_index do |line, i|
        case optional_flag
        when "-cv"
          ret = regexs.all? {|reg| line !~ reg}
          count += 1 if ret
        when "-Fc"
          ret = regexs.find {|reg| line.index(reg) != nil}
          count += 1 if ret
        end
      end
      script_ret += "#{file}: #{count}\n" if optional_flag == "-cv"
      script_ret += "#{file}: #{count}\n" if optional_flag == "-Fc"
    end
  end
  script_ret
end

def parseArgs(args)
  # Handles the 1, 2, 5 error case.
  return $usage if args.length < 2 or not continous_regex?(args)
  
  option_flags = get_option_flags(args)
  return $usage if not option_flags   # Handle 3 eror case.
  
  script_ret = ""     # Passed into func that requires to output to script
  
  files = get_files(args)
  return $usage if files.length == 0
  opened_files, script_ret = open_files(files, script_ret)
  
  regexs, script_ret = get_regexs(args, script_ret)
  
  if sum_flags(option_flags) == 3
    if option_flags["-F"] and option_flags["-v"] and option_flags["-c"]
      "-F -v -c"
    else
      return $usage
    end
  elsif sum_flags(option_flags) == 2
    if option_flags["-F"] and option_flags["-v"]
      "-F -v"
    elsif option_flags["-F"] and option_flags["-o"]
      "-F -o"
    elsif option_flags["-F"] and option_flags["-c"]
      regexs = args.filter {|arg| regex_format?(arg)}
      regexs = regexs.map {|arg| arg[1...-1]}
      script_ret = do_matching2(opened_files, regexs, script_ret, "-Fc")
    elsif option_flags["-c"] and option_flags["-v"]
      script_ret = do_matching2(opened_files, regexs, script_ret, "-cv")
    elsif option_flags["-o"] and option_flags["-c"]
      script_ret = do_matching(opened_files, regexs, script_ret, "-c")
    elsif option_flags["-A_NUM"] and option_flags["-v"]
      "-A_NUM -v"
    elsif option_flags["-B_NUM"] and option_flags["-v"]
      "-B_NUM -v"
    elsif option_flags["-C_NUM"] and option_flags["-v"]
      "-C_NUM -v"
    else
      return $usage
    end
  elsif sum_flags(option_flags) == 1
    if option_flags["-v"]
      script_ret = do_matching(opened_files, regexs, script_ret, "-v")
    elsif option_flags["-c"]
      script_ret = do_matching(opened_files, regexs, script_ret, "-c")
    elsif option_flags["-l"]
      script_ret = do_matching(opened_files, regexs, script_ret, "-l")
    elsif option_flags["-L"]
      script_ret = do_matching(opened_files, regexs, script_ret, "-L")
    elsif option_flags["-o"]
      script_ret = do_matching(opened_files, regexs, script_ret, "-o")
    elsif option_flags["-F"]
      regexs = args.filter {|arg| regex_format?(arg)}
      regexs = regexs.map {|arg| arg[1...-1]}
      script_ret = do_matching(opened_files, regexs, script_ret, "-F")
    elsif option_flags["-A_NUM"]
      script_ret = do_matching(opened_files, regexs, script_ret, "-A_NUM", option_flags["-A_NUM_P"])
    elsif option_flags["-B_NUM"]
      script_ret = do_matching(opened_files, regexs, script_ret, "-B_NUM", option_flags["-B_NUM_P"])
    else
      script_ret = do_matching(opened_files, regexs, script_ret, "-C_NUM", option_flags["-C_NUM_P"])
    end
  elsif sum_flags(option_flags) == 0
    script_ret = do_matching(opened_files, regexs, script_ret, "")
  else
    return $usage # Handle 4 error case.
  end
  return script_ret
end

puts parseArgs(args)
