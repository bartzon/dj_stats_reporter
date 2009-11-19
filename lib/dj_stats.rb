require File.dirname(__FILE__) + '/dj_stats/config'
require File.dirname(__FILE__) + '/dj_stats/dj_extensions'

module DjStats
  class Base
    include DjStats::Config
    include HTTParty
  
    cattr_accessor :stats_url, :app_name

    class << self
      def register_job(job)
        post @stats_url, :body => {:job => parse_job_attributes(job)}
        puts "Registered job #{job.to_param}"
        job
      end

      def start_job(job)
        attrs = parse_job_attributes(job)
        attrs.merge!(:started_at => Time.now.utc)
        put put_url(job), :body => {:job => attrs}
      end
    
      def end_job(job)
        attrs = parse_job_attributes(job)
        attrs.merge!(:ended_at => Time.now.utc)
        put put_url(job), :body => {:job => attrs}
      end
    
      private
        def parse_job_attributes(job)
          raise "Not a Delayed::Job" unless job.is_a?(Delayed::Job)   
          {
            :attempts => job.attempts,
            :priority => job.priority,
            :handler => job.handler,
            :application_name => @app_name,
            :remote_id => job.id
          }
        end
      
        def put_url(job)
          "#{@stats_url}/#{job.id}"
        end
    end
  end
end

DjStats::Base.init