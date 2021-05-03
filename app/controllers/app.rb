# frozen_string_literal: true

require 'roda'
require 'json'

module RestaurantCollections
  # Web controller for RestaurantCollections API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'RestaurantCollections API up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'restaurants' do
          @restaurant_route = "#{@api_root}/restaurants"

          routing.on String do |restaurant_id|
            routing.on 'meals' do
              @meal_route = "#{@api_root}/restaurants/#{restaurant_id}/meals"
              # GET api/v1/restaurants/[restaurant_id]/meals/[meal_id]
              routing.get String do |meal_id|
                meal = meal.where(restaurants_id: restaurant_id, id: meal_id).first
                meal ? meal.to_json : raise('meal not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/restaurants/[restaurant_id]/meals
              routing.get do
                output = { data: Restaurant.first(id: restaurant_id).meals }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find meals'
              end

              # POST api/v1/restaurants/[ID]/meals
              routing.post do
                new_data = JSON.parse(routing.body.read)
                restaurant = Restaurant.first(id: restaurant_id)
                new_meal = restaurant.add_mealument(new_data)

                if new_meal
                  response.status = 201
                  response['Location'] = "#{@meal_route}/#{new_meal.id}"
                  { message: 'mealument saved', data: new_meal }.to_json
                else
                  routing.halt 400, 'Could not save mealument'
                end

              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/restaurants/[ID]
            routing.get do
              restaurant = Restaurant.first(id: restaurant_id)
              restaurant ? restaurant.to_json : raise('Restaurant not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/restaurants
          routing.get do
            output = { data: Restaurant.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find restaurants' }.to_json
          end

          # POST api/v1/restaurants
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_restaurant = Restaurant.new(new_data)
            raise('Could not save Restaurant') unless new_restaurant.save

            response.status = 201
            response['Location'] = "#{@restaurant_route}/#{new_restaurant.id}"
            { message: 'Restaurant saved', data: new_restaurant }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
