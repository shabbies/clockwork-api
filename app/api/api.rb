require 'grape-swagger'

class API < Grape::API
  	prefix 'api'
  	version 'v1', using: :path

  	before do
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

    mount Listing
    mount Account
    mount Display
    mount Alert
    mount Gamify
    mount Competition
    add_swagger_documentation api_version: 'v1'
end

