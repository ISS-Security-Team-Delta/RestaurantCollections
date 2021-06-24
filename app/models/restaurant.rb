# frozen_string_literal: true

require 'json'
require 'sequel'

module RestaurantCollections

  # Restaurants' info
  class Restaurant < Sequel::Model
    many_to_one :owner, class: :'RestaurantCollections::Account'

    many_to_many :collaborators,
              class: :'RestaurantCollections::Account',
              join_table: :accounts_restaurants,
              left_key: :restaurant_id, right_key: :collaborator_id

    one_to_many :comments
    one_to_many :meals
    plugin :association_dependencies, comments: :destroy, collaborators: :nullify, meals: :destroy

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :website, :name, :address

    def to_h
      {
        type: 'restaurant',
        attributes: {
          id: id,
          website: website,
          name: name,
          address: address
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner: owner,
          collaborators: collaborators,
          comments: comments,
          meals: meals
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
