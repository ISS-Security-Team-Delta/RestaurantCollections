# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/restaurant'

module RestaurantCollections
  # Web controller for Credence API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Restaurant.setup
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'RestaurantCollection API up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'restaurants' do
            # GET api/v1/restaurants/[id]
            

            # GET api/v1/restaurants
            

            # POST api/v1/restaurants
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_restaurant = Restaurant.new(new_data)

              if new_restaurant.save
                response.status = 201
                { message: 'Restaurant saved', id: new_restaurant.id }.to_json
              else
                routing.halt 400, { message: 'Could not save restaurant' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
