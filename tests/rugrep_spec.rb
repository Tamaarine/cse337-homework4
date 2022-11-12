#  gem install simplecov for coverage
# uncomment the following two lines to generate coverage report
require 'simplecov'
SimpleCov.start
require_relative File.join("..", "src", "rugrep")

require './src/rugrep.rb'

describe "Func: regex_format?" do
  it "Should return false for a normal string" do
    expect(regex_format?("hello")).to eq false
  end
  
  it "Should return false for a normal string" do
    expect(regex_format?("this is not a regex")).to eq false
  end
  
  it "Should return false for empty string" do
    expect(regex_format?("")).to eq false
  end
  
  it "Should return false for half closed pat" do
    expect(regex_format?("\"half")).to eq false
  end
  
  it "Should return false for half closed empty string" do
    expect(regex_format?("\"")).to eq false
  end
  
  it "Should return false for half single quotes" do
    expect(regex_format?("\'")).to eq false
  end
  
  it "Should return false for two single quotes" do
    expect(regex_format?("\'\'")).to eq false
  end
  
  it "Should return true for double-quoted empty string" do
    expect(regex_format?("\"\"")).to eq true
  end
  
  it "Should return true for an invalid regex" do
    # Because the parsing of regex isn't handled in regex_format
    expect(regex_format?("\"[ab]+b\"")).to eq true
  end
  
  it "Should return true for an valid regex" do
    expect(regex_format?("\"abc\"")).to eq true
  end
  
  it "Should return true for nested double quotes" do
    expect(regex_format?("\"\"\"\"")).to eq true
  end
end

describe "Func: parse_regex" do
  it "Should return a regex object" do
    expect(parse_regex("\"[ab]\"")).to be_instance_of(Regexp)
  end
  
  it "Should return a regex object" do
    expect(parse_regex("\"/\d.\d/\"")).to be_instance_of(Regexp)
  end
  
  it "Should return nil since string doesn't conform specification" do
    expect(parse_regex("\"[ab]")).to be_nil
  end
  
  it "Should return a regex object, even an empty pattern" do
    expect(parse_regex("\"\"")).to be_instance_of(Regexp)
  end
  
  it "Should return nil with catch all exception" do
    expect(parse_regex(1)).to be_nil
  end
  
  it "Should return nil with RegexpError because of invalid regexp" do
    expect(parse_regex("\"[\"")).to be_nil
  end
end

describe "Func: continous_regex?" do
  it "Should return false because it cannot find a regex" do
    input = ["x", "al", "ababa", "-v"]
    expect(continous_regex?(input)).to eq false
  end
  
  it "Should return false because there is no regex" do
    input = ["x", "p"]
    expect(continous_regex?(input)).to eq false
  end
  
  it "Should return false no valid regex" do
    input = ["x", "\"p"]
    expect(continous_regex?(input)).to eq false
  end
  
  it "Should return true with one file & one valid regex" do
    input = ["x", "\"p\""]
    expect(continous_regex?(input)).to eq true
  end
  
  it "Should return false the regex is not continous" do
    input = ["a", "\"p\"", "a", "\"hehe\""]
    expect(continous_regex?(input)).to eq false
  end
  
  it "Should be true, half quoted string is not regex" do
    input = ["\"p\"", "\"hehe\"", "in", "the", "beg\""]
    expect(continous_regex?(input)).to eq true
  end
  
  it "Should be true, half quoted string is not regex" do
    input = ["in", "the", "beg\"", "\"p\"", "\"hehe\"", "\"", "file/file"]
    expect(continous_regex?(input)).to eq true
  end
  
  it "Should be false, regex after option/file" do
    input = ["in", "the", "beg\"", "\"p\"", "\"", "file/file", "\"hehe\""]
    expect(continous_regex?(input)).to eq false
  end
  
  it "Should be false, regex after option/file" do
    input = ["in", "the", "beg\"", "\"p\"", "\"", "file/file", "hehee", "hehee", "\"hehe\""]
    expect(continous_regex?(input)).to eq false
  end
  
  it "Should be true, bunch of regex after file/option" do
    input = ["in", "the", "beg\"", "\"p\"", "\"hehe\"", "\"hehe\"", "\"hehe\"", "\"hehe\"", "\"hehe\""]
    expect(continous_regex?(input)).to eq true
  end
end

describe "Func: valid_option?" do
  it "Should return -v" do
    expect(valid_option?("-v")).to eq "-v"
    expect(valid_option?("--invert-match")).to eq "-v"
  end
  
  it "Should return -c" do
    expect(valid_option?("-c")).to eq "-c"
    expect(valid_option?("--count")).to eq "-c"
  end
  
  it "Should return -l" do
    expect(valid_option?("-l")).to eq "-l"
    expect(valid_option?("--files-with-matches")).to eq "-l"
  end
  
  it "Should return -L" do
    expect(valid_option?("-L")).to eq "-L"
    expect(valid_option?("--files-without-match")).to eq "-L"
  end
  
  it "Should return -o" do
    expect(valid_option?("-o")).to eq "-o"
    expect(valid_option?("--only-matching")).to eq "-o"
  end
  
  it "Should return -F" do
    expect(valid_option?("-F")).to eq "-F"
    expect(valid_option?("--fixed-strings")).to eq "-F"
  end
  
  it "Should be able to identify -A/--after-context" do
    expect(valid_option?("-A_2")).to eq "-A_NUM"
    expect(valid_option?("--after-context=2")).to eq "-A_NUM"
  end
  
  it "Should be able to identify -B/--before-context" do
    expect(valid_option?("-B_2")).to eq "-B_NUM"
    expect(valid_option?("--before-context=2")).to eq "-B_NUM"
  end
  
  it "Should be able to identify -C/--context" do
    expect(valid_option?("-C_2")).to eq "-C_NUM"
    expect(valid_option?("--context=2")).to eq "-C_NUM"
  end
  
  it "Should be nil for invalid options" do
    expect(valid_option?("--hehe")).to be_nil
    expect(valid_option?("--oh no")).to be_nil
    expect(valid_option?("--oh no")).to be_nil
    expect(valid_option?("-A_a")).to be_nil
    expect(valid_option?("-B_b")).to be_nil
    expect(valid_option?("-C_c")).to be_nil
    expect(valid_option?("--after-context=x9")).to be_nil
    expect(valid_option?("--before-context=69420x")).to be_nil
    expect(valid_option?("--context=ohno")).to be_nil
  end
end

describe "Func: get_option_flags" do
  it "Should return false duplicate options" do
    input = ["--after-context=2", "\"b\"", "-v", "-c", "-c"]
    expect(get_option_flags(input)).to eq false
  end
  
  it "Should return false invalid options" do
    input = ["--after-context=2", "\"b\"", "-v", "-c", "-hehe"]
    expect(get_option_flags(input)).to eq false
  end
  
  it "Should return false duplicate options" do
    input = ["--after-context=a", "-A_2"]
    expect(get_option_flags(input)).to eq false
  end
  
  it "Should return a matching dictionary" do
    input = ["--after-context=2", "-v"]
    exp = {
      "-A_NUM" => true,
      "-A_NUM_P" => 2,
      "-B_NUM" => false,
      "-C_NUM" => false,
      "-F" => false,
      "-l" => false,
      "-L" => false,
      "-c" => false,
      "-o" => false,
      "-v" => true
    }
    expect(get_option_flags(input)).to eq exp
  end
  
  it "Should return a matching dictionary" do
    input = ["--after-context=2", "-v", "-B_4"]
    exp = {
      "-A_NUM" => true,
      "-A_NUM_P" => 2,
      "-B_NUM" => true,
      "-B_NUM_P" => 4,
      "-C_NUM" => false,
      "-F" => false,
      "-l" => false,
      "-L" => false,
      "-c" => false,
      "-o" => false,
      "-v" => true
    }
    expect(get_option_flags(input)).to eq exp
  end
  
  it "Should return false invalid option" do
    input = ["--after-context=2", "-v", "-B_4", "-B"]
    expect(get_option_flags(input)).to eq false
  end
  
  it "Should return a matching dictionary" do
    input = ["-A_3", "--before-context=3", "-C_5", "-F", "-l", "-L", "-c", "-o", "-v"]
    exp = {
      "-A_NUM" => true,
      "-A_NUM_P" => 3,
      "-B_NUM" => true,
      "-B_NUM_P" => 3,
      "-C_NUM" => true,
      "-C_NUM_P" => 5,
      "-F" => true,
      "-l" => true,
      "-L" => true,
      "-c" => true,
      "-o" => true,
      "-v" => true
    }
    expect(get_option_flags(input)).to eq exp
  end
  
  it "Should return false" do
    input = ["-A_a", "--before-context=3", "-C_5", "-F", "-l", "-L", "-c", "-o", "-v"]
    expect(get_option_flags(input)).to eq false
  end
end

describe "Func: sum_flags" do
  it "Should return 0" do
    exp = {
      "-A_NUM" => false,
      "-A_NUM_P" => 2,
      "-B_NUM" => false,
      "-B_NUM_P" => 3,
      "-C_NUM" => false,
      "-C_NUM_P" => 5,
      "-F" => false,
      "-l" => false,
      "-c" => false,
      "-L" => false,
      "-o" => false,
      "-v" => false
    }
    expect(sum_flags(exp)).to eq 0
  end
  
  it "Should return 8" do
    exp = {
      "-A_NUM" => true,
      "-A_NUM_P" => 3,
      "-B_NUM" => false,
      "-B_NUM_P" => 3,
      "-C_NUM" => true,
      "-C_NUM_P" => 5,
      "-F" => true,
      "-l" => true,
      "-L" => true,
      "-c" => true,
      "-o" => true,
      "-v" => true
    }
    expect(sum_flags(exp)).to eq 8
  end
end

describe "Func: get_files" do
  it "Should return the matching files" do
    args = [
      "hehe",
      "-v",
      "hehe/hi",
      "\"regex\"",
      "-A_2"
    ]
    exp = ["hehe", "hehe/hi"]
    expect(get_files(args)).to eq exp
  end
  
  it "Should return the matching files" do
    args = [
      "-v",
      "\"regex\"",
      "-A_2"
    ]
    exp = []
    expect(get_files(args)).to eq exp
  end
  
  it "Should return the matching files" do
    args = [
      "-v",
      "\"regex\"",
      "-A_2",
      "\"[az]pple\""
    ]
    exp = []
    expect(get_files(args)).to eq exp
  end
  
  it "Should return the matching files" do
    args = [
      "-v",
      "\"regex\"",
      "-A_2",
      "\"[az]pple\"",
      "--count",
      "--invert-match",
      "hello world"
    ]
    exp = ["hello world"]
    expect(get_files(args)).to eq exp
  end
end

describe "Func: get_regexs" do
  it "Should return an empty list" do
    input = ["hehe", "file/example.txt", "files/html.html"]
    script_ret = ""
    ret, script_ret = get_regexs(input, script_ret)
    expect(ret).to eq []
    expect(script_ret).to eq ""
  end
  
  it "Should return matching list" do
    input = ["hehe", "file/example.txt", "\"[az]pple\"","files/html.html"]
    script_ret = ""
    ret, script_ret = get_regexs(input, script_ret)
    exp = [/[az]pple/]
    expect(ret).to eq exp
    expect(script_ret).to eq ""
  end
  
  it "Should return matching list with matching script_ret" do
    input = ["hehe", "file/example.txt", "\"[az]pple\"", "\"[\"","files/html.html"]
    script_ret = ""
    ret, script_ret = get_regexs(input, script_ret)
    exp = [/[az]pple/]
    expect(ret).to eq exp
    expect(script_ret).to eq "Error: cannot parse regex \"[\"\n"
  end
  
  it "Should return matching list with matching script_ret" do
    input = ["hehe", "file/example.txt", "\"[az]pple\"", "\"[\"", "\"?\"","files/html.html"]
    script_ret = ""
    ret, script_ret = get_regexs(input, script_ret)
    exp = [/[az]pple/]
    expect(ret).to eq exp
    expect(script_ret).to eq "Error: cannot parse regex \"[\"\nError: cannot parse regex \"?\"\n"
  end
end

describe "Func: open_files" do
  it "Should return an empty map with no mappings" do
    files = ["haha", "xd", "not", "valid"]
    script_ret = ""
    ret, script_ret = open_files(files, script_ret)
    expect(ret).to eq Hash.new
    expect(script_ret).to eq "Error: could not read file haha\nError: could not read file xd\nError: could not read file not\nError: could not read file valid\n"
  end
  
  it "Should return an mapping of two files and preserve previous script_ret value" do
    files = ["tmp/othello.txt", "tmp/exists.txt","tmp/example.html"]
    script_ret = "wa"
    ret, script_ret = open_files(files, script_ret)
    exp = [
      "tmp/othello.txt",
      "tmp/example.html"
    ]
    expect(ret.keys).to eq exp
    expect(script_ret).to eq "waError: could not read file tmp/exists.txt\n"
  end
end

describe "Func: parseArgs" do
  it "Should return the matching lines" do
    input = ["tmp/othello.txt", "tmp/example.html", "\"</?body>\"", "\"personal\"", "\"ship\""]
    exp = "tmp/othello.txt: In personal suit to make me his lieutenant,\ntmp/othello.txt: "\
          "Is all his soldiership. But he, sir, had the election:\ntmp/othello.txt: "\
          "And I--God bless the mark!--his Moorship's ancient.\ntmp/example.html: "\
          "<body>\ntmp/example.html: </body>\n"
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching lines" do
    input = ["tmp/othello.txt", "hehe", "\"</?body>\"", "\"personal\"", "\"ship\""]
    exp = <<~HEREDOC
    Error: could not read file hehe
    In personal suit to make me his lieutenant,
    Is all his soldiership. But he, sir, had the election:
    And I--God bless the mark!--his Moorship's ancient.
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching lines inverted matches" do
    input = ["tmp/othello.txt", "-v", "\"in|mark\""]
    exp = <<~HEREDOC
    Despise me, if I do not. Three great ones of the city,
    In personal suit to make me his lieutenant,
    Off-capp'd to him: and, by the faith of man,
    I know my price, I am worth no worse a place:
    Evades them, with a bombast circumstance
    Horribly stuff'd with epithets of war;
    Nonsuits my mediators; for, 'Certes,' says he,
    'I have already chose my officer.'
    And what was he?
    Forsooth, a great arithmetician,
    Nor the division of a battle knows
    As masterly as he: mere prattle, without practise,
    Is all his soldiership. But he, sir, had the election:
    And I, of whom his eyes had seen the proof
    At Rhodes, at Cyprus and on other grounds
    Christian and heathen, must be be-lee'd and calm'd
    By debitor and creditor: this counter-caster,
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching lines inverted matches" do
    input = ["tmp/othello.txt", "-v", "\"in|mark\"", "\"Cyprus|Cassio\""]
    exp = <<~HEREDOC
    Despise me, if I do not. Three great ones of the city,
    In personal suit to make me his lieutenant,
    Off-capp'd to him: and, by the faith of man,
    I know my price, I am worth no worse a place:
    Evades them, with a bombast circumstance
    Horribly stuff'd with epithets of war;
    Nonsuits my mediators; for, 'Certes,' says he,
    'I have already chose my officer.'
    And what was he?
    Forsooth, a great arithmetician,
    Nor the division of a battle knows
    As masterly as he: mere prattle, without practise,
    Is all his soldiership. But he, sir, had the election:
    And I, of whom his eyes had seen the proof
    Christian and heathen, must be be-lee'd and calm'd
    By debitor and creditor: this counter-caster,
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching lines inverted matches" do
    input = ["tmp/othello.txt", "tmp/example.html", "-v", "\"in|mark\"", "\"Cyprus|Cassio\"",
      "\"</?body>\""
    ]
    exp = <<~HEREDOC
    tmp/othello.txt: Despise me, if I do not. Three great ones of the city,
    tmp/othello.txt: In personal suit to make me his lieutenant,
    tmp/othello.txt: Off-capp'd to him: and, by the faith of man,
    tmp/othello.txt: I know my price, I am worth no worse a place:
    tmp/othello.txt: Evades them, with a bombast circumstance
    tmp/othello.txt: Horribly stuff'd with epithets of war;
    tmp/othello.txt: Nonsuits my mediators; for, 'Certes,' says he,
    tmp/othello.txt: 'I have already chose my officer.'
    tmp/othello.txt: And what was he?
    tmp/othello.txt: Forsooth, a great arithmetician,
    tmp/othello.txt: Nor the division of a battle knows
    tmp/othello.txt: As masterly as he: mere prattle, without practise,
    tmp/othello.txt: Is all his soldiership. But he, sir, had the election:
    tmp/othello.txt: And I, of whom his eyes had seen the proof
    tmp/othello.txt: Christian and heathen, must be be-lee'd and calm'd
    tmp/othello.txt: By debitor and creditor: this counter-caster,
    tmp/example.html: <!DOCTYPE html>
    tmp/example.html: <html>
    tmp/example.html: 
    tmp/example.html: <p>This is a paragraph.</p>
    tmp/example.html: <p>This is another paragraph.</p>
    tmp/example.html: 
    tmp/example.html: </html>
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching lines inverted matches" do
    input = ["tmp/othello.txt", "tmp/example.html", "-v", "\"in|mark\"", "\"Cyprus|Cassio\"",
      "\"<.+>\""
    ]
    exp = <<~HEREDOC
    tmp/othello.txt: Despise me, if I do not. Three great ones of the city,
    tmp/othello.txt: In personal suit to make me his lieutenant,
    tmp/othello.txt: Off-capp'd to him: and, by the faith of man,
    tmp/othello.txt: I know my price, I am worth no worse a place:
    tmp/othello.txt: Evades them, with a bombast circumstance
    tmp/othello.txt: Horribly stuff'd with epithets of war;
    tmp/othello.txt: Nonsuits my mediators; for, 'Certes,' says he,
    tmp/othello.txt: 'I have already chose my officer.'
    tmp/othello.txt: And what was he?
    tmp/othello.txt: Forsooth, a great arithmetician,
    tmp/othello.txt: Nor the division of a battle knows
    tmp/othello.txt: As masterly as he: mere prattle, without practise,
    tmp/othello.txt: Is all his soldiership. But he, sir, had the election:
    tmp/othello.txt: And I, of whom his eyes had seen the proof
    tmp/othello.txt: Christian and heathen, must be be-lee'd and calm'd
    tmp/othello.txt: By debitor and creditor: this counter-caster,
    tmp/example.html: 
    tmp/example.html: 
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return a number of matching lines" do
    input = ["tmp/othello.txt", "-c", "\"in|mark\"", "\"Cyprus|Cassio\""]
    exp = "10\n"
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return a number of matching lines" do
    input = ["tmp/othello.txt", "tmp/example.html", "-c", "\"in|mark\"", "\"Cyprus|Cassio\"",
      "\"<.+>\""
    ]
    exp = <<~HEREDOC
    tmp/othello.txt: 10
    tmp/example.html: 7
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return a number of matching lines" do
    input = ["tmp/othello.txt", "tmp/example.html", "tmp/sample.html",
      "-c", "\"in|mark\"", "\"Cyprus|Cassio\"", "\"<.+>\""
    ]
    exp = <<~HEREDOC
    tmp/othello.txt: 10
    tmp/example.html: 7
    tmp/sample.html: 88
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching expected files" do
    input = ["tmp/othello.txt", "tmp/example.html", "tmp/sample.html",
      "-l", "\"in|mark\"", "\"Cyprus|Cassio\""
    ]
    exp = <<~HEREDOC
    othello.txt
    sample.html
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching expected files" do
    input = ["tmp/othello.txt", "tmp/example.html", "tmp/sample.html",
      "-l", "\"in|mark\"", "\"Cyprus|Cassio\"", "\"<.+>\""
    ]
    exp = <<~HEREDOC
    othello.txt
    example.html
    sample.html
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return no matching files" do
    input = ["tmp/othello.txt", "tmp/example.html", "tmp/sample.html",
      "-l", "\"axe\""
    ]
    exp = <<~HEREDOC
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return all files because none of them matches" do
    input = ["tmp/othello.txt", "tmp/example.html", "tmp/sample.html",
      "-L", "\"axe\""
    ]
    exp = <<~HEREDOC
    othello.txt
    example.html
    sample.html
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return only example.html and sample.html" do
    input = ["tmp/othello.txt", "tmp/example.html", "tmp/sample.html",
      "-L", "\"personal\""
    ]
    exp = <<~HEREDOC
    example.html
    sample.html
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return only example.html and sample.html" do
    input = ["tmp/othello.txt", "tmp/example.html", "tmp/sample.html",
      "-L", "\"personal\"", "\"\\d{4}\""
    ]
    exp = <<~HEREDOC
    example.html
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello.txt", "-o", "\"personal\"", "\"\\d{4}\"", "\"in|mark\""]
    exp = <<~HEREDOC
    personal
    in
    in
    in
    in
    in
    in
    in
    in
    mark
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/sample.html", "-o", "\"personal\"", "\"\\d{4}\"", "\"in|mark\""]
    exp = <<~HEREDOC
    0014
    in
    1252
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/sample.html", "-o", "\"personal\"", "\"in|mark\"", "\"\\d{4}\""]
    exp = <<~HEREDOC
    in
    0014
    in
    1252
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    in
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/example.html", "tmp/othello.txt", "-o", "\"personal\"", "\"Cyprus|Cassio\"", "\"<.+>\""]
    exp = <<~HEREDOC
    tmp/example.html: <!DOCTYPE html>
    tmp/example.html: <html>
    tmp/example.html: <body>
    tmp/example.html: <p>This is a paragraph.</p>
    tmp/example.html: <p>This is another paragraph.</p>
    tmp/example.html: </body>
    tmp/example.html: </html>
    tmp/othello.txt: personal
    tmp/othello.txt: Cassio
    tmp/othello.txt: Cyprus
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/example.html", "-F", "\"\n\""]
    exp = <<~HEREDOC
    <!DOCTYPE html>
    <html>
    <body>

    <p>This is a paragraph.</p>
    <p>This is another paragraph.</p>

    </body>
    </html>
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/example.html", "-F", "\"\\n\""]
    exp = <<~HEREDOC
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/example.html", "tmp/poem.txt", "-F", "\"\\n\"",
      "\"<.+>\""
    ]
    exp = <<~HEREDOC
    <.+>
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/example.html", "tmp/poem.txt", "-F", "\"\\n\"",
      "\"<.+>\"", "\"no|light\""
    ]
    exp = <<~HEREDOC
    no|light
    <.+>
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello.txt", "-B_2", "\"spinster\""]
    exp = <<~HEREDOC
    That never set a squadron in the field,
    Nor the division of a battle knows
    More than a spinster; unless the bookish theoric,
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello.txt", "tmp/example.html", "-B_2", "\"spinster\""]
    exp = <<~HEREDOC
    tmp/othello.txt: That never set a squadron in the field,
    tmp/othello.txt: Nor the division of a battle knows
    tmp/othello.txt: More than a spinster; unless the bookish theoric,
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello.txt", "tmp/example.html", "-B_2", "\"spinster\"",
      "\"paragraph\""
    ]
    exp = <<~HEREDOC
    tmp/othello.txt: That never set a squadron in the field,
    tmp/othello.txt: Nor the division of a battle knows
    tmp/othello.txt: More than a spinster; unless the bookish theoric,
    tmp/example.html: <body>
    tmp/example.html: 
    tmp/example.html: <p>This is a paragraph.</p>
    --
    tmp/example.html: 
    tmp/example.html: <p>This is a paragraph.</p>
    tmp/example.html: <p>This is another paragraph.</p>
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello.txt", "tmp/sample.html", "-B_2", "\"spinster\"",
      "\"text/css\""
    ]
    exp = <<~HEREDOC
    tmp/othello.txt: That never set a squadron in the field,
    tmp/othello.txt: Nor the division of a battle knows
    tmp/othello.txt: More than a spinster; unless the bookish theoric,
    tmp/sample.html: //-->
    tmp/sample.html: </script>
    tmp/sample.html: <style type="text/css">
    --
    tmp/sample.html: //-->
    tmp/sample.html: </script>
    tmp/sample.html: <style type="text/css">
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello.txt", "tmp/sample.html", "-A_2", "\"man\"",
      "\"text/css\"", "\"window.gbWhTopic\""
    ]
    exp = <<~HEREDOC
    tmp/othello.txt: Off-capp'd to him: and, by the faith of man,
    tmp/othello.txt: I know my price, I am worth no worse a place:
    tmp/othello.txt: But he; as loving his own pride and purposes,
    tmp/sample.html: <style type="text/css">
    tmp/sample.html: <!--
    tmp/sample.html: img_whs1 { border:none; width:301px; height:295px; float:none; }
    --
    tmp/sample.html: <style type="text/css">
    tmp/sample.html: <!--
    tmp/sample.html: div.WebHelpPopupMenu { position:absolute; left:0px; top:0px; z-index:4; visibility:hidden; }
    --
    tmp/sample.html: if (window.gbWhTopic)
    tmp/sample.html: {
    tmp/sample.html:     if (window.setRelStartPage)
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello_m.txt", "-A_0", "\"i\""]
    exp = <<~HEREDOC
    Despise me, if I do not. Three great ones of the city,
    --
    In personal suit to make me his lieutenant,
    --
    Off-capp'd to him: and, by the faith of man,
    --
    I know my price, I am worth no worse a place:
    --
    But he; as loving his own pride and purposes,
    --
    Evades them, with a bombast circumstance
    --
    Horribly stuff'd with epithets of war;
    --
    And, in conclusion,
    --
    Nonsuits my mediators; for, 'Certes,' says he,
    --
    'I have already chose my officer.'
    --
    Forsooth, a great arithmetician,
    --
    One Michael Cassio, a Florentine,
    --
    A fellow almost damn'd in a fair wife;
    --
    That never set a squadron in the field,
    --
    Nor the division of a battle knows
    --
    More than a spinster; unless the bookish theoric,
    --
    Wherein the toged consuls can propose
    --
    As masterly as he: mere prattle, without practise,
    --
    Is all his soldiership. But he, sir, had the election:
    --
    And I, of whom his eyes had seen the proof
    --
    Christian and heathen, must be be-lee'd and calm'd
    --
    By debitor and creditor: this counter-caster,
    --
    He, in good time, must his lieutenant be,
    --
    And I--God bless the mark!--his Moorship's ancient.
    --
    i love you!
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello_m.txt", "-A_1", "\"i\""]
    exp = <<~HEREDOC
    Despise me, if I do not. Three great ones of the city,
    In personal suit to make me his lieutenant,
    --
    In personal suit to make me his lieutenant,
    Off-capp'd to him: and, by the faith of man,
    --
    Off-capp'd to him: and, by the faith of man,
    I know my price, I am worth no worse a place:
    --
    I know my price, I am worth no worse a place:
    But he; as loving his own pride and purposes,
    --
    But he; as loving his own pride and purposes,
    Evades them, with a bombast circumstance
    --
    Evades them, with a bombast circumstance
    Horribly stuff'd with epithets of war;
    --
    Horribly stuff'd with epithets of war;
    And, in conclusion,
    --
    And, in conclusion,
    Nonsuits my mediators; for, 'Certes,' says he,
    --
    Nonsuits my mediators; for, 'Certes,' says he,
    'I have already chose my officer.'
    --
    'I have already chose my officer.'
    And what was he?
    --
    Forsooth, a great arithmetician,
    One Michael Cassio, a Florentine,
    --
    One Michael Cassio, a Florentine,
    A fellow almost damn'd in a fair wife;
    --
    A fellow almost damn'd in a fair wife;
    That never set a squadron in the field,
    --
    That never set a squadron in the field,
    Nor the division of a battle knows
    --
    Nor the division of a battle knows
    More than a spinster; unless the bookish theoric,
    --
    More than a spinster; unless the bookish theoric,
    Wherein the toged consuls can propose
    --
    Wherein the toged consuls can propose
    As masterly as he: mere prattle, without practise,
    --
    As masterly as he: mere prattle, without practise,
    Is all his soldiership. But he, sir, had the election:
    --
    Is all his soldiership. But he, sir, had the election:
    And I, of whom his eyes had seen the proof
    --
    And I, of whom his eyes had seen the proof
    At Rhodes, at Cyprus and on other grounds
    --
    Christian and heathen, must be be-lee'd and calm'd
    By debitor and creditor: this counter-caster,
    --
    By debitor and creditor: this counter-caster,
    He, in good time, must his lieutenant be,
    --
    He, in good time, must his lieutenant be,
    And I--God bless the mark!--his Moorship's ancient.
    --
    And I--God bless the mark!--his Moorship's ancient.
    --
    --
    i love you!
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello_m.txt", "-C_1", "\"Cyprus\"",
      "\"says he\""
    ]
    exp = <<~HEREDOC
    And, in conclusion,
    Nonsuits my mediators; for, 'Certes,' says he,
    'I have already chose my officer.'
    --
    And I, of whom his eyes had seen the proof
    At Rhodes, at Cyprus and on other grounds
    Christian and heathen, must be be-lee'd and calm'd
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello.txt", "-C_5", "\"Cyprus\"",
      "\"says he\""
    ]
    exp = <<~HEREDOC
    I know my price, I am worth no worse a place:
    But he; as loving his own pride and purposes,
    Evades them, with a bombast circumstance
    Horribly stuff'd with epithets of war;
    And, in conclusion,
    Nonsuits my mediators; for, 'Certes,' says he,
    'I have already chose my officer.'
    And what was he?
    Forsooth, a great arithmetician,
    One Michael Cassio, a Florentine,
    A fellow almost damn'd in a fair wife;
    --
    More than a spinster; unless the bookish theoric,
    Wherein the toged consuls can propose
    As masterly as he: mere prattle, without practise,
    Is all his soldiership. But he, sir, had the election:
    And I, of whom his eyes had seen the proof
    At Rhodes, at Cyprus and on other grounds
    Christian and heathen, must be be-lee'd and calm'd
    By debitor and creditor: this counter-caster,
    He, in good time, must his lieutenant be,
    And I--God bless the mark!--his Moorship's ancient.
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching output" do
    input = ["tmp/othello.txt", "tmp/sample.html","-C_1", "\"ancient\"",
      "\"grounds\"", "\"</body>\"", "\"wiredminds.count()\""
    ]
    exp = <<~HEREDOC
    tmp/othello.txt: And I, of whom his eyes had seen the proof
    tmp/othello.txt: At Rhodes, at Cyprus and on other grounds
    tmp/othello.txt: Christian and heathen, must be be-lee'd and calm'd
    --
    tmp/othello.txt: He, in good time, must his lieutenant be,
    tmp/othello.txt: And I--God bless the mark!--his Moorship's ancient.
    tmp/sample.html: wm_track_alt='';
    tmp/sample.html: wiredminds.count();
    tmp/sample.html: // -->
    --
    tmp/sample.html: <!-- WiredMinds eMetrics tracking with Enterprise Edition V5.4 END -->
    tmp/sample.html: </body>
    tmp/sample.html: </html>
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return usage" do
    input = ["-v", "-d"]
    expect(parseArgs(input)).to eq "USAGE: ruby rugrep.rb"
  end
  
  it "Should return usage" do
    input = ["tmp/othello.txt", "-F", "-c", "-o", "\"temp\""]
    expect(parseArgs(input)).to eq "USAGE: ruby rugrep.rb"
  end
  
  it "Should return usage" do
    input = ["-F", "-c", "-o", "-v", "tmp/othello.txt", "\"temp\""]
    expect(parseArgs(input)).to eq "USAGE: ruby rugrep.rb"
  end
  
  it "Should return usage" do
    input = ["tmp/te", "\"temp\""]
    expect(parseArgs(input)).to eq "Error: could not read file tmp/te\n"
  end
  
  it "Should return the matching number of line counts" do
    input = ["tmp/othello_m.txt", "\"personal\"", "\"\\.\"",
      "\"text/css\"", "-c", "tmp/othello.txt", "tmp/sample.html"
    ]
    exp = <<~HEREDOC
    tmp/othello_m.txt: 5
    tmp/othello.txt: 5
    tmp/sample.html: 48
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching number of line counts" do
    input = ["tmp/othello_m.txt", "\"personal\"", "\"\\.\"",
      "\"text/css\"", "-c", "tmp/ohno.txt"
    ]
    exp = <<~HEREDOC
    Error: could not read file tmp/ohno.txt
    5
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching number of line counts" do
    input = ["tmp/othello_m.txt", "\"in|mark\"",
      "-c", "-v"
    ]
    expect(parseArgs(input)).to eq "19\n"
  end
  
  it "Should return the matching number of line counts" do
    input = ["tmp/othello_m.txt", "tmp/sample.html", "\"in|mark\"",
      "\"text/css\"", "-c", "-v"
    ]
    exp = <<~HEREDOC
    tmp/othello_m.txt: 19
    tmp/sample.html: 139
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the matching number of line counts" do
    input = ["tmp/weird.txt", '"http[s]?://"', '-F', '-c'
    ]
    expect(parseArgs(input)).to eq "1\n"
  end
  
  it "Should return the matching number of line counts" do
    input = ["tmp/weird.txt", '"http[s]?://"',
      '"child"', '-F', '-c'
    ]
    expect(parseArgs(input)).to eq "3\n"
  end
  
  it "Should return the matching number of line counts" do
    input = ["tmp/weird.txt", "tmp/sample.html", '"http[s]?://"',
      '"http://"', '-F', '-c'
    ]
    exp = <<~HEREDOC
    tmp/weird.txt: 3
    tmp/sample.html: 1
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the string" do
    input = ["tmp/weird.txt", "-o", "tmp/sample.html", '"http[s]?://"',
      '"http://"', '-F'
    ]
    exp = <<~HEREDOC
    tmp/weird.txt: http[s]?://
    tmp/weird.txt: http://
    tmp/weird.txt: http://
    tmp/sample.html: http://
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the string" do
    input = ["tmp/weird.txt", "-o", '"http[s]?://xd"',
      '"http://xd"', '-F'
    ]
    exp = <<~HEREDOC
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the string" do
    input = ["tmp/weird.txt", "-v", '"http[s]?://xd"',
      '"License"', '"TXT"', '"c"', '-F'
    ]
    exp = <<~HEREDOC
    Purpose: Provide example of this file type
    Version: 1.0
    Remark:
    
    
    
    
    
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the string" do
    input = ["tmp/weird.txt", "-v", '"http[s]?://xd"',
      '"License"', '"TXT"', '"c"', '-F'
    ]
    exp = <<~HEREDOC
    Purpose: Provide example of this file type
    Version: 1.0
    Remark:
    
    
    
    
    
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
  
  it "Should return the string" do
    input = ["tmp/weird.txt", "-v", '"http[s]?://xd"',
      '"License"', '"TXT"', '"c"', '-F', "tmp/othello_m.txt"
    ]
    exp = <<~HEREDOC
    tmp/weird.txt: Purpose: Provide example of this file type
    tmp/weird.txt: Version: 1.0
    tmp/weird.txt: Remark:
    tmp/weird.txt: 
    tmp/weird.txt: 
    tmp/weird.txt: 
    tmp/weird.txt: 
    tmp/weird.txt: 
    tmp/othello_m.txt: In personal suit to make me his lieutenant,
    tmp/othello_m.txt: But he; as loving his own pride and purposes,
    tmp/othello_m.txt: Horribly stuff'd with epithets of war;
    tmp/othello_m.txt: Nonsuits my mediators; for, 'Certes,' says he,
    tmp/othello_m.txt: And what was he?
    tmp/othello_m.txt: A fellow almost damn'd in a fair wife;
    tmp/othello_m.txt: That never set a squadron in the field,
    tmp/othello_m.txt: Nor the division of a battle knows
    tmp/othello_m.txt: And I, of whom his eyes had seen the proof
    tmp/othello_m.txt: At Rhodes, at Cyprus and on other grounds
    tmp/othello_m.txt: He, in good time, must his lieutenant be,
    tmp/othello_m.txt: --
    tmp/othello_m.txt: i love you!
    HEREDOC
    expect(parseArgs(input)).to eq exp
  end
end
