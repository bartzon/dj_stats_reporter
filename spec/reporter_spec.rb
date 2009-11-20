require File.dirname(__FILE__) + '/spec_helper'

class Job < Delayed::Job
  def initialize; end
  
  def attempts;   1; end
  def priority;   2; end
  def handler;    'handler'; end
  def id;         3; end
  def last_error; 'error'; end
  
  def method_missing(foo); end
end

describe DjStats::Reporter do
  before(:each) do
    @job = Job.new
    
    DjStats::Config.stub!(:app_name).and_return "Test App"
    
    @attrs = { :application_name => "Test App", 
               :remote_id => 3, 
               :handler => "handler", 
               :attempts => 1, 
               :last_error => "error", 
               :priority => 2 }
  end

  describe "sending a request" do
    it "should wrap the error in a DjStats::Error" do
      DjStats::Reporter.stub!(:post).and_raise "Foo"
      lambda { DjStats::Reporter.register_job(@job) }.should raise_error(DjStats::Error, "Foo")
    end
  end
  
  describe "registering a job" do
    before(:each) do
      DjStats::Reporter.stub!(:post).and_return true
    end
    
    def do_register
      DjStats::Reporter.register_job(@job)
    end
    
    it "should call the correct method with the correct arguments" do
      DjStats::Reporter.should_receive(:post).with("http://localhost:3000/", :body => {:job => @attrs})
      do_register
    end
    
    it "should return the job" do
      do_register.should == @job
    end
  end
  
  describe "starting a job" do
    before(:each) do
      DjStats::Reporter.stub!(:put).and_return true   
    end
    
    def do_start
      DjStats::Reporter.start_job(@job)
    end
    
    it "should call the correct method with the correct arguments" do
      Time.stub!(:now).and_return Time.utc(2009,1,1)
      attrs = @attrs.dup.merge!(:started_at => Time.utc(2009,1,1))
      DjStats::Reporter.should_receive(:put).with("http://localhost:3000/3", :body => {:job => attrs})
      do_start
    end
    
    it "should return the job" do
      do_start.should == @job
    end
  end
  
  describe "ending a job" do
    before(:each) do
      DjStats::Reporter.stub!(:delete).and_return true   
    end
    
    def do_end
      DjStats::Reporter.end_job(@job)
    end

    it "should call the correct method with the correct arguments" do
      Time.stub!(:now).and_return Time.utc(2009,1,1)
      attrs = @attrs.dup.merge!(:ended_at => Time.utc(2009,1,1))
      DjStats::Reporter.should_receive(:delete).with("http://localhost:3000/3", :body => {:job => attrs})
      do_end
    end
    
    it "should return the job" do
      do_end.should == @job
    end
  end

  describe "rescheduling a job" do
    it "should call the correct method with the correct attributes" do
      attrs = @attrs.dup.merge!(:started_at => nil)
      DjStats::Reporter.should_receive(:put).with("http://localhost:3000/3", :body => {:job => attrs})
      DjStats::Reporter.reschedule_job(@job)
    end
  end
  
  describe "failing a job" do
    before(:each) do
      DjStats::Reporter.stub!(:put)
      @t = Time.utc(2009,1,1)
      Time.stub!(:now).and_return @t
    end
    
    def do_fail
      DjStats::Reporter.fail_job(@job)
    end
    
    it "should call the correct method with the correct attributes" do
      attrs = @attrs.dup
      attrs.merge!(:ended_at => @t)
      attrs.merge!(:failed_at => @t)
      DjStats::Reporter.should_receive(:put).with("http://localhost:3000/3", :body => {:job => attrs})
      do_fail
    end
    
    it "should return the job" do
      do_fail.should == @job
    end
  end
end