ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:meals].delete
  app.DB[:comments].delete
  app.DB[:restaurants].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:meals] = YAML.safe_load File.read('app/db/seeds/meal_seeds.yml')
DATA[:comments] = YAML.safe_load File.read('app/db/seeds/comment_seeds.yml')
DATA[:restaurants] = YAML.safe_load File.read('app/db/seeds/restaurant_seeds.yml')
