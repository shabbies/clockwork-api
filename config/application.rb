require File.expand_path('../boot', __FILE__)
 
require 'rails/all'
require 'rack/cors'

 
Bundler.require(*Rails.groups)
 
module Clockwork
  class Application < Rails::Application
    ## Newly Added code to set up the api code
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    #application.rb
	config.middleware.use Rack::Cors do
	  allow do
	    origins '*'

	    # location of your API
	    resource '/api/v1/*', :headers => :any, :methods => [:get, :post, :options, :put]
	  end
	end
  end
end