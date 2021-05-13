# frozen_string_literal: true

require 'json'
require 'sequel'

module RestaurantCollections

  # Meal info
  class Meal < Sequel::Model
    many_to_one :restaurant

    plugin :uuid, field: :id
    plugin :timestamps

    plugin :whitelist_security
    set_allowed_columns :categories, :name, :name_eng, :cost, :description

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end
    
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'meal',
            attributes: {
              id: id,
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
