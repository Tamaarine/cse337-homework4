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
  
  it "Should be able to identity -A/--after-context" do
    expect(valid_option?("-A_2")[0]).to eq "-A_2"
    expect(valid_option?("-A_2")[2]).to eq "2"
    expect(valid_option?("-A_")[2]).to eq ""
    expect(valid_option?("--after-context=2")[0]).to eq "--after-context=2"
    expect(valid_option?("--after-context=2")[2]).to eq "2"
    expect(valid_option?("--after-context=")[2]).to eq ""
  end
  
  it "Should be able to identity -B/--before-context" do
    expect(valid_option?("-B_2")[0]).to eq "-B_2"
    expect(valid_option?("-B_2")[2]).to eq "2"
    expect(valid_option?("-B_")[2]).to eq ""
    expect(valid_option?("--before-context=2")[0]).to eq "--before-context=2"
    expect(valid_option?("--before-context=2")[2]).to eq "2"
    expect(valid_option?("--before-context=")[2]).to eq ""
  end
  
  it "Should be able to identity -C/--context" do
    expect(valid_option?("-C_2")[0]).to eq "-C_2"
    expect(valid_option?("-C_2")[2]).to eq "2"
    expect(valid_option?("-C_")[2]).to eq ""
    expect(valid_option?("--context=2")[0]).to eq "--context=2"
    expect(valid_option?("--context=2")[2]).to eq "2"
    expect(valid_option?("--context=")[2]).to eq ""
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