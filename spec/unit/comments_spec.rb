# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Comment Handling' do
  before do
    wipe_database

    DATA[:restaurants].each do |restaurant_data|
      RestaurantCollections::Restaurant.create(restaurant_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    com_data = DATA[:comments][1]
    rest = RestaurantCollections::Restaurant.first
    new_com = rest.add_comment(com_data)

    com = RestaurantCollections::Comment.find(id: new_com.id)
    _(com.content).must_equal new_com.content
  end

  it 'SECURITY: should not use deterministic integers' do
    com_data = DATA[:comments][1]
    rest = RestaurantCollections::Restaurant.first
    new_com = rest.add_comment(com_data)

    _(new_com.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    com_data = DATA[:comments][1]
    rest = RestaurantCollections::Restaurant.first
    new_com = rest.add_comment(com_data)
    stored_com = app.DB[:comments].first

    _(stored_com[:content_secure]).wont_equal new_com.content
  end
end
