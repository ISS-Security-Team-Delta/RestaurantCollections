# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  RestaurantCollections::Comment.map(&:destroy)
  RestaurantCollections::Meal.map(&:destroy)
  RestaurantCollections::Restaurant.map(&:destroy)
  RestaurantCollections::Account.map(&:destroy)
end

def authenticate(account_data)
  RestaurantCollections::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  contents = AuthToken.contents(auth[:attributes][:auth_token])
  account = contents['payload']['attributes']
  { account: RestaurantCollections::Account.first(username: account['username']),
    scope: AuthScope.new(contents['scope']) }
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml')),
  comments: YAML.load(File.read('app/db/seeds/comments_seed.yml')),
  meals: YAML.load(File.read('app/db/seeds/meals_seed.yml')),
  restaurants: YAML.load(File.read('app/db/seeds/restaurants_seed.yml'))
}.freeze

## SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load(
  File.read('spec/fixtures/github_token_response.yml')
)
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
SSO_ACCOUNT = YAML.load(File.read('spec/fixtures/sso_account.yml'))
