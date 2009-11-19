module DjStats
  class Reporter
    include HTTParty
    
    class << self
      def register_job(job)
        send_job :post, parse_job_attributes(job)
        job
      end

      def start_job(job)
        attrs = parse_job_attributes(job)
        attrs.merge!(:started_at => Time.now.utc)
        send_job :put, attrs
      end
    
      def end_job(job)
        attrs = parse_job_attributes(job)
        attrs.merge!(:ended_at => Time.now.utc)
        send_job :put, attrs
      end
    
      private
        def send_job(method, attrs)
          url = DjStats::Config.stats_url
          case method
            when :post
              post url, :body => {:job => attrs}
            when :put
              put "#{url}/#{job.id}", :body => {:job => attrs}
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