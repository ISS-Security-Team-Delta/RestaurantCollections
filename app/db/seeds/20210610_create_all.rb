# frozen_string_literal: true

require './app/controllers/helpers.rb'
include RestaurantCollections::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, restaurants, comments, meals, collaborators'
    create_accounts
    create_owned_restaurants
    create_comments
    create_meals
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_restaurants.yml")
REST_INFO = YAML.load_file("#{DIR}/restaurants_seed.yml")
COMMENT_INFO = YAML.load_file("#{DIR}/comments_seed.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/restaurants_collaborators.yml")
MEALS_INFO = YAML.load_file("#{DIR}/meals_seed.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    RestaurantCollections::Account.create(account_info)
  end
end

def create_owned_restaurants
  OWNER_INFO.each do |owner|
    account = RestaurantCollections::Account.first(username: owner['username'])
    owner['rest_name'].each do |rest_name|
      rest_data = REST_INFO.find { |rest| rest['name'] == rest_name }
      account.add_owned_restaurant(rest_data)
    end
  end
end

def create_meals
  meals_info_each = MEALS_INFO.each
  restaurants_cycle = RestaurantCollections::Restaurant.all.cycle
  loop do
    meals_info = meals_info_each.next
    restaurant = restaurants_cycle.next

    auth_token = AuthToken.create(restaurant.owner)
    auth = scoped_auth(auth_token)

    RestaurantCollections::CreateMealForRestaurant.call(
      auth: auth, restaurant: restaurant, meal_data: meals_info
    )
  end
end

def create_comments
  com_info_each = COMMENT_INFO.each
  restaurants_cycle = RestaurantCollections::Restaurant.all.cycle
  loop do
    com_info = com_info_each.next
    restaurant = restaurants_cycle.next

    auth_token = AuthToken.create(restaurant.owner)
    auth = scoped_auth(auth_token)

    RestaurantCollections::CreateCommentForRestaurant.call(
      auth: auth, restaurant: restaurant, comment_data: com_info
    )
  end
end

def add_collaborators
  contrib_info = CONTRIB_INFO
  contrib_info.each do |contrib|
    restaurant = RestaurantCollections::Restaurant.first(name: contrib['rest_name'])

    auth_token = AuthToken.create(restaurant.owner)
    auth = scoped_auth(auth_token)

    contrib['collaborator_email'].each do |email|
      RestaurantCollections::AddCollaborator.call(
        auth: auth, restaurant: restaurant, collab_email: email
      )
    end
  end
end