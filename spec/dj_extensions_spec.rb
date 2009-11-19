require File.dirname(__FILE__) + '/spec_helper'

class Job < Delayed::Job
  def initialize; end
  
  def attempts;   1; end
  def priority;   2; end
  def handler;    'handler'; end
  def id;         3; end
  def last_error; 'error'; end
  
  def method_missing(foo); end
  def respond_to?(m, m2=nil); end
  def self.columns; []; end
end

describe Delayed::Job do
  before(:each) do
    @job = Job.new
  end
  
  describe "enqueing jobs" do
    it "should register a job correctly" do
      Delayed::Job.should_receive(:enqueue_without_stats).with("foo").and_return @job
      DjStats::Reporter.should_receive(:register_job).with(@job)
      Delayed::Job.enqueue("foo")
    end
  end
  
  describe "running jobs" do
    before(:each) do
      DjStats::Reporter.stub!(:start_job)
      DjStats::Reporter.stub!(:end_job)
      @job.stub!(:run_with_lock_without_stats).and_return true
    end
    
    def do_run
      @job.run_with_lock(0, 0)
    end
    
    it "should start a job correctly" do
      DjStats::Reporter.should_receive(:start_job).with(@job)
      do_run
    end
    
    it "should end a job correctly" do      
      DjStats::Reporter.should_receive(:end_job).with(@job)
      do_run
    end
    
    it "should reschedule a job correctly" do
      @job.stub!(:run_with_lock_without_stats).and_return false
      DjStats::Reporter.should_receive(:reschedule_job).with(@job)
      do_run
    end

  end
  
  describe "failing jobs" do
    before(:each) do
      @job.stub!(:reschedule_without_stats)
      DjStats::Reporter.stub!(:fail_job)
    end
    
    def do_reschedule
      @job.reschedule('message')
    end
    
    it "should fail a job if DJ deleted it" do
      @job.stub!(:frozen?).and_return true
      DjStats::Reporter.should_receive(:fail_job).with(@job)
      do_reschedule
    end

    it "should fail a job if DJ has set failed_at" do
      @job.stub!(:failed_at).and_return true
      DjStats::Reporter.should_receive(:fail_job).with(@job)
      do_reschedule
    end
  end
end
