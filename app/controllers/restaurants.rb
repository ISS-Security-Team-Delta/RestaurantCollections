# frozen_string_literal: true

require 'roda'
require_relative './app'

module RestaurantCollections
  # Web controller for RestaurantCollections API
  class Api < Roda
    route('restaurants') do |routing|
      @rest_route = "#{@api_root}/restaurants"

      routing.on String do |restaurant_id|
        routing.on 'comments' do
          @com_route = "#{@api_root}/restaurants/#{restaurant_id}/comments"
          # GET api/v1/restaurants/[restaurant_id]/comments/[com_id]
          routing.get String do |com_id|
            com = Comment.where(restaurant_id: restaurant_id, id: com_id).first
            com ? com.to_json : raise('Comment not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/restaurants/[restaurant_id]/comments
          routing.get do
            output = { data: Restaurant.first(id: restaurant_id).comments }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt(404, { message: 'Could not find comments' }.to_json)
          end

          # POST api/v1/restaurants/[restaurant_id]/comments
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_com = CreateCommentForRestaurant.call(
              restaurant_id: restaurant_id, comment_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@com_route}/#{new_com.id}"
            { message: 'Comment saved', data: new_com }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError
            routing.halt 500, { message: 'Database error' }.to_json
          end
        end

        # GET api/v1/restaurants/[restaurant_id]
        routing.get do
          rest = Restaurant.first(id: restaurant_id)
          rest ? rest.to_json : raise('Restaurant not found')
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
        new_rest = Restaurant.new(new_data)
        raise('Could not save Restaurant') unless new_rest.save

        response.status = 201
        response['Location'] = "#{@restaurant_id}/#{new_rest.id}"
        { message: 'Restaurant saved', data: new_rest }.to_json
        
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end

#{"data":{"type":"restaurant","attributes":{"id":402,"website":"hehept2.com","name":"hehe2","address":"hehe2 street","menu":"yummy food pt 2"}}}