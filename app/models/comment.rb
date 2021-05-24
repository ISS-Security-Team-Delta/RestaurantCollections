# frozen_string_literal: true

require 'json'
require 'sequel'

module RestaurantCollections
  # Comment info
  class Comment < Sequel::Model
    many_to_one :restaurant

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :content, :like

    # encrypt content
    def content
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
              content: content,
              like: like
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
