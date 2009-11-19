require File.dirname(__FILE__) + '/dj_stats/config'
require File.dirname(__FILE__) + '/dj_stats/dj_extensions'

module DjStats
  class Error < StandardError; end
  
  class Base
  end
end

DjStats::Config.init