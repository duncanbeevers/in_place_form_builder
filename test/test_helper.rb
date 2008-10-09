$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

# Setup
require 'test/unit'
require 'rubygems'
begin; require 'turn'; rescue LoadError; end # I like this gem for test result output

require 'active_record'
require 'active_support'
require 'action_controller'
require 'action_view'

require 'active_support/test_case'
require 'action_controller/test_process'

# require 'action_controller/base'
# require 'action_controller/request_forgery_protection'
require 'action_view/test_case'

require 'ruby-debug'
Debugger.settings[:autoeval] = true
Debugger.start

require 'test/models'
require 'test/routes'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.configurations = config
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

load(File.join(File.dirname(__FILE__), 'schema.rb'))
require File.join(File.dirname(__FILE__), '../init')

ActionController::Base.send(:include, ActionController::RequestForgeryProtection)
