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
      logger.info "[JOB] Starting job #{self.id}"
      DjStats::Reporter.start_job(self)

      if run_with_lock_without_stats(max_run_time, worker_name)
        logger.info "[JOB] Ending job #{self.id}"
        DjStats::Reporter.end_job(self)
      end
    end
  end
end
