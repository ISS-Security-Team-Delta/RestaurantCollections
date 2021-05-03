# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module RestaurantCollections

  # Comment info
  class Comment < Sequel::Model
    many_to_one :restaurant
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :contents, :likes

    def to_json(options = {})
      JSON(
        {
            data: {
              type: 'comment',
              attributes: {
                contents: contents,
                likes: likes
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
