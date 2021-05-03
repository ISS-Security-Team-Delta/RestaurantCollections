# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative './test_load_all'

def wipe_database
  app.DB[:restaurants].delete
  app.DB[:comments].delete
  app.DB[:meals].delete

end

DATA = {}
DATA[:restaurants] = YAML.safe_load File.read('app/db/seeds/restaurant_seeds.yml')
DATA[:comments] = YAML.safe_load File.read('app/db/seeds/restaurant_seeds.yml')
DATA[:meals] = YAML.safe_load File.read('app/db/seeds/restaurant_seeds.yml')
