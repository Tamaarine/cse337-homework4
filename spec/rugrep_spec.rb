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