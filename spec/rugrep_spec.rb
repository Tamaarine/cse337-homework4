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