$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

RAILS_ROOT = File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'active_record'
require 'delayed_job'
require 'httparty'

require 'dj_stats'
require 'dj_stats/config'
require 'dj_stats/reporter'
