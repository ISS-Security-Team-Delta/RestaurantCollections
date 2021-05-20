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
          routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username: username)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Project saved', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            puts e.inspect
            routing.halt 500, { message: error.message }.to_json
          end
        end
        routing.on 'restaurants' do
          @restaurant_route = "#{@api_root}/restaurants"

          routing.on String do |restaurant_id|
            routing.on 'comments' do
              @comment_route = "#{@api_root}/restaurants/#{restaurant_id}/comments"
              # GET api/v1/restaurants/[restaurant_id]/comments/[comment_id]
              routing.get String do |comment_id|
                comment = Comment.where(restaurants_id: restaurant_id, id: comment_id).first
                comment ? comment.to_json : raise('comment not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/restaurants/[restaurant_id]/comments
              routing.get do
                output = { data: Restaurant.first(id: restaurant_id).comments }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find comments'
              end

              # POST api/v1/restaurants/[restaurant_id]/comments
              routing.post do
                new_data = JSON.parse(routing.body.read)
                restaurant = Restaurant.first(id: restaurant_id)
                new_comment = restaurant.add_comment(new_data)
                raise 'Could not save comment' unless new_comment

                response.status = 201
                response['Location'] = "#{@comment_route}/#{new_comment.id}"
                { message: 'comment saved', data: new_comment }.to_json

              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end

            routing.on 'meals' do
              @meal_route = "#{@api_root}/restaurants/#{restaurant_id}/meals"
              # GET api/v1/restaurants/[restaurant_id]/meals/[meal_id]
              routing.get String do |meal_id|
                meal = Meal.where(restaurants_id: restaurant_id, id: meal_id).first
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

              # POST api/v1/restaurants/[restaurant_id]/meals
              routing.post do
                new_data = JSON.parse(routing.body.read)
                restaurant = Restaurant.first(id: restaurant_id)
                new_meal = restaurant.add_meal(new_data)

                raise 'Could not save meal' unless new_meal

                response.status = 201
                response['Location'] = "#{@meal_route}/#{new_meal.id}"
                { message: 'meal saved', data: new_meal }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/restaurants/[restaurant_id]
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
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: "Unknown server error" }.to_json
          end
        end
      end
    end
  end
end
