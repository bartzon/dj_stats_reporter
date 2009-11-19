module DjStats
  class Reporter
    include HTTParty
    
    class << self
      def register_job(job)
        send_job :post, parse_job_attributes(job)
        puts "Registering #{job.id}"
        job
      end

      def start_job(job)
        attrs = parse_job_attributes(job)
        attrs.merge!(:started_at => Time.now.utc)
        send_job :put, attrs, job.id
        puts "Starting #{job.id}"
        job
      end
    
      def end_job(job)
        attrs = parse_job_attributes(job)
        attrs.merge!(:ended_at => Time.now.utc)
        send_job :delete, attrs, job.id
        puts "deleteing #{job.id}"
        job
      end
      
      def reschedule_job(job)
        attrs = parse_job_attributes(job)
        attrs.merge!(:started_at => nil)
        send_job :put, attrs, job.id
        puts "Rescheduling #{job.id}"
        job
      end
      
      def fail_job(job)
        attrs = parse_job_attributes(job)
        attrs.merge!(:ended_at => Time.now.utc)
        attrs.merge!(:failed_at => Time.now.utc)
        send_job :put, attrs, job.id
        puts "Failing #{job.id}"
        job
      end
    
      private
        def send_job(method, attrs, id=nil)
          url = [DjStats::Config.stats_url, id].join("/")
          begin
            send method, url, :body => {:job => attrs}
          rescue => e
            raise DjStats::Error.new(e.message)
          end
        end
        
        def parse_job_attributes(job)
          raise "Not a Delayed::Job" unless job.is_a?(Delayed::Job)   
          {
            :attempts => job.attempts,
            :priority => job.priority,
            :handler => job.handler,
            :application_name => DjStats::Config.app_name,
            :remote_id => job.id,
            :last_error => job.last_error
          }
        end
    end
  end
end