require File.dirname(__FILE__) + '/spec_helper'

describe DjStats::Config do
  describe "init" do
    before(:each) do
      @config_file = "#{RAILS_ROOT}/config/dj_stats.yml"
      @config = File.open(@config_file)
      File.stub!(:open).and_return @config
    end
    
    it "should open the correct config file" do
      File.should_receive(:open).with(@config_file).and_return @config  
      DjStats::Config.init
    end
    
    it "should raise an error if the file cannot be found" do
      File.stub!(:open).and_return nil
      lambda { DjStats::Config.init }.should raise_error("Could not open #{@config_file}")
    end
    
    it "should parse the config file" do
      YAML.should_receive(:load).with(@config).and_return "dj_stats"
      DjStats::Config.init
    end
    
    it "should raise an error if the config file has an invalid format" do
      YAML.stub!(:load).and_return 'foo'
      lambda { DjStats::Config.init }.should raise_error("Incorrect format of dj_stats.yml")
    end
    
    it "should set the stats_url" do
      DjStats::Config.init
      DjStats::Config.stats_url.should == 'http://localhost:3000'
    end
    
    it "should set the app_name" do
      DjStats::Config.init
      DjStats::Config.app_name.should == 'Test App'
    end
  end
end