# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module RestaurantCollections
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_restaurants, class: :'RestaurantCollections::Restaurant', key: :owner_id
    plugin :association_dependencies, owned_restaurants: :destroy

    many_to_many :collaborations,
                 class: :'RestaurantCollections::Restaurant',
                 join_table: :accounts_restaurants,
                 left_key: :collaborator_id, right_key: :restaurant_id

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def restaurants
      owned_restaurants + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      puts "Password digest: #{password_digest}"
      digest = RestaurantCollections::Password.from_digest(password_digest)
      puts "The output digest to compare is: #{digest}"
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username: username,
            email: email
          }
        }, options
      )
    end
  end
end
