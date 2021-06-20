# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module RestaurantCollections
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_restaurants, class: :'RestaurantCollections::Restaurant', key: :owner_id

    many_to_many :collaborations,
                 class: :'RestaurantCollections::Restaurant',
                 join_table: :accounts_restaurants,
                 left_key: :collaborator_id, right_key: :restaurant_id
    
    plugin :association_dependencies, 
           owned_restaurants: :destroy, 
           collaborations: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def self.create_github_account(github_account)
      create(username: github_account[:username],
             email: github_account[:email])
    end

    def restaurants
      owned_restaurants + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = RestaurantCollections::Password.from_digest(password_digest)
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
