require File.expand_path('../boot', __FILE__)
 
require 'rails/all'
 
Bundler.require(*Rails.groups)
 
module Clockwork
  class Application < Rails::Application
    ## Newly Added code to set up the api code
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]
  end
end