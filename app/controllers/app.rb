# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './helpers'

module RestaurantCollections
  # Web controller for RestaurantCollections API
  class Api < Roda
    include SecureRequestHelpers
    plugin :halt
    plugin :multi_route
    plugin :request_headers

    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    route do |routing|

      begin
        @auth_account = authenticated_account(routing.headers)
      rescue AuthToken::InvalidTokenError
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      end

      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      routing.root do
        { message: 'RestaurantCollections API up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end
