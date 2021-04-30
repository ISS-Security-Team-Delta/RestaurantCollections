# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

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
    get '/api/v1/restaurants/abcd' ### To be revised
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new restaurants' do
    existing_store = DATA[:restaurants][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/restaurants', existing_store.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    store = RestaurantCollections::Restaurant.first

    _(created['id']).must_equal store.id
    _(created['name']).must_equal existing_store['name']
    _(created['website']).must_equal existing_store['website']
  end
end
