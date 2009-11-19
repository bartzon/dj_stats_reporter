module Delayed
  class Job < ActiveRecord::Base
    class << self
      alias_method :enqueue_without_stats, :enqueue
      def enqueue(*args, &block)
        job = enqueue_without_stats(*args, &block)
        DjStats::Reporter.register_job(job)
      end
    end

    alias_method :run_with_lock_without_stats, :run_with_lock
    def run_with_lock(max_run_time, worker_name)
      DjStats::Reporter.start_job(self)

      result = run_with_lock_without_stats(max_run_time, worker_name)
      case result
        when nil   # lock failed
        when true  # work done
          DjStats::Reporter.end_job(self)
        when false # reschedule
          DjStats::Reporter.reschedule_job(self)
      end
    end
    
    alias_method :reschedule_without_stats, :reschedule
    def reschedule(message, backtrace = [], time = nil)
      reschedule_without_stats(message, backtrace, time)

      if frozen? || failed_at
        DjStats::Reporter.fail_job(self)
      end
    end
  end
end
