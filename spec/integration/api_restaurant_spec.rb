# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

    before do
      wipe_database
    end

    describe 'Getting projects' do
      it 'HAPPY: should be able to get list of all restaurants' do
        RestaurantCollections::Restaurant.create(DATA[:restaurants][0]).save
        RestaurantCollections::Restaurant.create(DATA[:restaurants][1]).save

        get 'api/v1/restaurants'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'HAPPY: should be able to get details of a single restaurant' do
        existing_store = DATA[:restaurants][1]
        RestaurantCollections::Restaurant.create(existing_store).save
        id = RestaurantCollections::Restaurant.first.id

        get "/api/v1/restaurants/#{id}"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data']['attributes']['id']).must_equal id
        _(result['data']['attributes']['name']).must_equal existing_store['name']
      end

      it 'SAD: should return error if unknown project requested' do
        get '/api/v1/restaurants/foobar'
        _(last_response.status).must_equal 404
      end

      it 'SECURITY: should prevent basic SQL injection targeting IDs' do
        RestaurantCollections::Restaurant.create(name: 'New Project')
        RestaurantCollections::Restaurant.create(name: 'Newer Project')
        get 'api/v1/restaurants/2%20or%20id%3E0'

        # deliberately not reporting error -- don't give attacker information
        _(last_response.status).must_equal 404
        _(last_response.body['data']).must_be_nil
      end
    end

  describe 'Creating New Restaurants' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @restaurant_data = DATA[:restaurants][1]
    end

    it 'HAPPY: should be able to create new restaurants' do
      post 'api/v1/restaurants', @restaurant_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      restaurant = RestaurantCollections::Restaurant.first

      _(created['id']).must_equal restaurant.id
      _(created['name']).must_equal @restaurant_data['name']
      _(created['website']).must_equal @restaurant_data['website']
    end

#      it 'SECURITY: should not create restaurant with mass assignment' do
#        bad_data = @restaurant_data.clone
#        bad_data['created_at'] = '1900-01-01'
#        post 'api/v1/restaurants', bad_data.to_json, @req_header
#
#        _(last_response.status).must_equal 400
#        _(last_response.header['Location']).must_be_nil
#      end
    end
end
