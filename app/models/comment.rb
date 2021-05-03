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
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :contents, :likes

    # encrypt content
    def content_secure
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
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
