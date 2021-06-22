# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Restaurant Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = RestaurantCollections::Account.create(@account_data)
    @wrong_account = RestaurantCollections::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting restaurants' do
    describe 'Getting list of restaurants' do
      before do
        @account.add_owned_restaurant(DATA[:restaurants][0])
        @account.add_owned_restaurant(DATA[:restaurants][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/restaurants'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/restaurants'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single restaurant' do
      rest = @account.add_owned_restaurant(DATA[:restaurants][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/restaurants/#{rest.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal rest.id
      _(result['attributes']['name']).must_equal rest.name
    end

    it 'SAD: should return error if unknown restaurant requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/restaurants/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get restaurant with wrong authorization' do
      rest = @account.add_owned_restaurant(DATA[:restaurants][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/restaurants/#{rest.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_restaurant(DATA[:restaurants][0])
      @account.add_owned_restaurant(DATA[:restaurants][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/restaurants/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Restaurants' do
    before do
      @rest_data = DATA[:restaurants][0]
    end

    it 'HAPPY: should be able to create new restaurants' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/restaurants', @rest_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      rest = RestaurantCollections::Restaurant.first

      _(created['id']).must_equal rest.id
      _(created['name']).must_equal @rest_data['name']
    end

    it 'SAD: should not create new restaurant without authorization' do
      post 'api/v1/restaurants', @rest_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create restaurant with mass assignment' do
      bad_data = @rest_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/restaurants', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
