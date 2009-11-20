module DjStats
  class Config
    class << self
      def init
        yaml = YAML.load(load_file)

        if yaml["dj_stats"]
          @stats_url = [yaml["dj_stats"]["stats_url"], "jobs"].join('/')
          @app_name  = yaml["dj_stats"]["application_name"]
        else
          raise DjStats::Error.new("Incorrect format of dj_stats.yml")
        end
      end
    
      def stats_url
        @stats_url
      end
      
      def app_name
        @app_name
      end
      
      private
        def load_file
          name = File.join(RAILS_ROOT, "config", "dj_stats.yml")
          File.open(name) || raise(DjStats::Error.new("Could not open #{name}"))
        end
    end
  end
end