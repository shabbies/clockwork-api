require "resque/tasks"
require 'grape'
require "resque"
require 'active_record'
require 'devise'

task "resque:setup" => :environment do
	# raise "Please set your RESQUE_WORKER variable to true" unless ENV['RESQUE_WORKER'] == "true"
	ENV['QUEUE'] ||= '*'
	root_path = "#{File.dirname(__FILE__)}/../.."
  require "#{root_path}/app/api/account.rb"
	db_config = YAML::load(File.open(File.join(root_path,'config','database.yml')))[Rails.env]
	Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection(db_config) }
end