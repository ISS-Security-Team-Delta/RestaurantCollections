# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module RestaurantCollections

  # Meal info
  class Meal < Sequel::Model
    many_to_one :restaurant
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :categories, :name, :name_eng, :cost, :description

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'meal',
            attributes: {
              categories: categories,
              name: name,
              name_eng: name_eng,
              cost: cost,
              description: description
            }
          },
          included: {
            restaurant: restaurant
          }
        }, options
      )
    end
  end
end
