# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative './test_load_all'

def wipe_database
  app.DB[:comments].delete
  app.DB[:restaurants].delete
  app.DB[:accounts].delete
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/accounts_seeds.yml')),
  restaurants: YAML.load(File.read('app/db/seeds/restaurants_seeds.yml')),
  comments: YAML.load(File.read('app/db/seeds/comments_seeds.yml'))
}.freeze
