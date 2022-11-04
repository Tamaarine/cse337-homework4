require './src/rugrep.rb'

describe "Func: regex?" do
  it "Should return false for a normal string" do
    expect(regex?("hello")).to eq false
  end
  
  it "Should return false for a normal string" do
    expect(regex?("this is not a regex")).to eq false
  end
  
  it "Should return false for empty string" do
    expect(regex?("")).to eq false
  end
  
  it "Should return false for half closed pat" do
    expect(regex?("\"half")).to eq false
  end
  
  it "Should return false for half closed empty string" do
    expect(regex?("\"")).to eq false
  end
  
  it "Should return false for half single quotes" do
    expect(regex?("\'")).to eq false
  end
  
  it "Should return false for two single quotes" do
    expect(regex?("\'\'")).to eq false
  end
  
  it "Should return true for double-quoted empty string" do
    expect(regex?("\"\"")).to eq true
  end
  
  it "Should return true for an invalid regex" do
    # Because the parsing of regex isn't handled in regex?
    expect(regex?("\"[ab]+b\"")).to eq true
  end
  
  it "Should return true for an valid regex" do
    expect(regex?("\"abc\"")).to eq true
  end
  
  it "Should return true for nested double quotes" do
    expect(regex?("\"\"\"\"")).to eq true
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