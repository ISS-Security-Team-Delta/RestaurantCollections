# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Comment Handling' do
  include Rack::Test::Methods

  before do
    puts "Wiping the database!"
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = RestaurantCollections::Account.create(@account_data)
    @account.add_owned_restaurant(DATA[:restaurants][0])
    @account.add_owned_restaurant(DATA[:restaurants][1])
    RestaurantCollections::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single comment' do
    it 'HAPPY: should be able to get details of a single comment' do
      com_data = DATA[:comments][0]
      rest = @account.restaurants.first
      com = rest.add_comment(com_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/comments/#{com.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal com.id
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      com_data = DATA[:comments][1]
      rest = RestaurantCollections::Restaurant.first
      com = rest.add_comment(com_data)

      get "/api/v1/comments/#{com.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      com_data = DATA[:comments][0]
      rest = @account.restaurants.first
      com = rest.add_comment(com_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/comments/#{com.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if comment does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/comments/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Comments' do
    before do
      @rest = RestaurantCollections::Restaurant.first
      @com_data = DATA[:comments][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/restaurants/#{@rest.id}/comments", @com_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      com = RestaurantCollections::Comment.first

      _(created['id']).must_equal com.id
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/restaurants/#{@rest.id}/comments", @com_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/restaurants/#{@rest.id}/comments", @com_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @com_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/restaurants/#{@rest.id}/comments", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
