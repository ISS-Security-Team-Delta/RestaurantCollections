# frozen_string_literal: true

require 'roda'
require_relative './app'

module RestaurantCollections
  # Web controller for RestaurantCollections API
  class Api < Roda
    route('meals') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @meal_route = "#{@api_root}/meals"

      # GET api/v1/meals/[meal_id]
      routing.on String do |meal_id|
        @req_meal = Meal.first(id: meal_id)

        routing.get do
          meal = GetMealQuery.call(
            auth: @auth, meal: @req_meal
          )

          { data: meal }.to_json
        rescue GetMealQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetMealQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET MEAL ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
