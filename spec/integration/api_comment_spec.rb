# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Comment Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:restaurants].each do |rest_data|
      RestaurantCollections::Restaurant.create(rest_data)
    end
  end

  it 'HAPPY: should be able to get list of all comments' do
    rest = RestaurantCollections::Restaurant.first
    DATA[:comments].each do |com|
      rest.add_comment(com)
    end

    get "api/v1/restaurants/#{rest.id}/comments"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single comment' do
    com_data = DATA[:comments][1]
    rest = RestaurantCollections::Restaurant.first
    com = rest.add_comment(com_data)

    get "/api/v1/restaurants/#{rest.id}/comments/#{com.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal com.id
    _(result['data']['attributes']['contents']).must_equal com_data['contents']
  end

  it 'SAD: should return error if unknown comment requested' do
    rest = RestaurantCollections::Restaurant.first
    get "/api/v1/restaurants/#{rest.id}/comments/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Comments' do
    before do
      @rest = RestaurantCollections::Restaurant.first
      @com_data = DATA[:comments][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new comments' do
      post "api/v1/restaurants/#{@rest.id}/comments",
           @com_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      com = RestaurantCollections::Restaurant.first

      _(created['id']).must_equal com.id
      _(created['contents']).must_equal @com_data['contents']
      _(created['likes']).must_equal @com_data['likes']
    end

    it 'SECURITY: should not create comments with mass assignment' do
      bad_data = @com_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/restaurants/#{@rest.id}/comments",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
