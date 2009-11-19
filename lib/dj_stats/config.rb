module DjStats
  module Config
    def self.included(klass)
      klass.send :extend, ClassMethods
    end
    
    module ClassMethods
      def init
        yaml = YAML.load(File.open(File.join(RAILS_ROOT, "config", "dj_stats.yml")))

        if yaml["dj_stats"]
          @stats_url = yaml["dj_stats"]["stats_url"]
          @app_name  = yaml["dj_stats"]["application_name"]
        else
          raise "Incorrect format of dj_stats.yml"
        end
      end
    end
  end
end