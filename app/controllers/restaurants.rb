# frozen_string_literal: true

require 'roda'
require_relative './app'

module RestaurantCollections
  # Web controller for RestaurantCollections API
  class Api < Roda
    route('restaurants') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @rest_route = "#{@api_root}/restaurants"
      routing.on String do |restaurant_id|
        @req_restaurant = Restaurant.first(id: restaurant_id)

        # GET api/v1/restaurants/[restaurant_id]
        routing.get do
          #binding.pry
          restaurant = GetRestaurantQuery.call(auth: @auth, restaurant: @req_restaurant)

          { data: restaurant }.to_json
        rescue GetRestaurantQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetRestaurantQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND RESTAURANT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on 'comments' do
          # POST api/v1/restaurants/[restaurant_id]/comments
          routing.post do
            new_comment = CreateCommentForRestaurant.call(
              auth: @auth,
              restaurant: @req_restaurant,
              comment_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@com_route}/#{new_comment.id}"
            { message: 'Comment saved', data: new_comment }.to_json
          rescue CreateCommentForRestaurant::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateCommentForRestaurant::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE_COMMENT_ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on 'meals' do
          # POST api/v1/restaurants/[restaurant_id]/meals
          routing.post do
            new_meal = CreateMealForRestaurant.call(
              auth: @auth,
              restaurant: @req_restaurant,
              meal_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@meal_route}/#{new_meal.id}"
            { message: 'Meal saved', data: new_meal }.to_json
          rescue CreateMealForRestaurant::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateMealForRestaurant::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE_MEAL_ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('collaborators') do
          # PUT api/v1/restaurants/[restaurant_id]/collaborators
          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaboratorToRestaurant.call(
              auth: @auth,
              restaurant: @req_restaurant,
              collab_email: req_data['email']
            )

            { data: collaborator }.to_json
          rescue AddCollaboratorToRestaurant::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/restaurants/[restaurant_id]/collaborators
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            collaborator = RemoveCollaborator.call(
              auth: @auth,
              collab_email: req_data['email'],
              restaurant_id: restaurant_id
            )

            { message: "#{collaborator.username} removed from restaurant",
              data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/restaurants
        routing.get do
          restaurants = RestaurantPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: restaurants)
        rescue StandardError
          routing.halt 403, { message: 'Could not find restaurants' }.to_json
        end

        # POST api/v1/restaurants
        routing.post do
          new_data = JSON.parse(routing.body.read)
          puts "Entered API putting data from route: #{new_data}"
          new_rest = CreateRestaurantForOwner.call(
            auth: @auth, restaurant_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@rest_route}/#{new_rest.id}"
          { message: 'Restaurant saved', data: new_rest }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue CreateRestaurantForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
