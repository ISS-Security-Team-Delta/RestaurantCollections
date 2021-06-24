# frozen_string_literal: true

require 'json'
require 'sequel'

module RestaurantCollections
  # Comment info
  class Meal < Sequel::Model
    many_to_one :restaurant

    plugin :timestamps

    plugin :whitelist_security
    set_allowed_columns :name, :description, :type, :price

    def to_json(options = {})
      JSON(
        {
          type: 'meal',
          attributes: {
            id: id,
            name: name,
            description: description,
            type: type,
            price: price
          },
          included: {
            restaurant: restaurant
          }
        }, options
      )
    end
  end
end
