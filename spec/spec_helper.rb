ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:restaurants].delete
end

DATA = {}
DATA[:restaurants] = YAML.safe_load File.read('app/db/seeds/restaurant_seeds.yml')
