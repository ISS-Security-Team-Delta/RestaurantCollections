# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module RestaurantCollections
  # Comment info
  class Comment < Sequel::Model
    many_to_one :restaurant

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :contents, :likes

    # encrypt content
    def contents
      SecureDB.decrypt(contents_secure)
    end

    def contents=(plaintext)
      puts plaintext
      self.contents_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'comment',
            attributes: {
              id: id,
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
