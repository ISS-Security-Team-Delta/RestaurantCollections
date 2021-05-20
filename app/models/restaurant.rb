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
    plugin :association_dependencies, comments: :destroy, collaborators: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :website, :name, :address, :menu

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'restaurant',
            attributes: {
              id: id,
              website: website,
              name: name,
              address: address,
              menu: menu
            }
          }
        }, options
      )
    end
  end
end
