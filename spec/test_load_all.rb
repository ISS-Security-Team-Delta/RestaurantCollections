# frozen_string_literal: true

# run pry -r <path/to/this/file>
# require 'rack/test'
# include Rack::Test::Methods # rubocop:disable Style/MixinUsage

require_relative '../require_app'
require_app

def app
  RestaurantCollections::Api
end

unless app.environment == :production
  require 'rack/test'
  include Rack::Test::Methods # rubocop:disable Style/MixinUsage
end
