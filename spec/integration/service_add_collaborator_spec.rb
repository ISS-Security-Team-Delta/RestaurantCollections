# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaborator service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      RestaurantCollections::Account.create(account_data)
    end

    restaurant_data = DATA[:restaurants].first

    @owner_data = DATA[:accounts][0]
    @owner = RestaurantCollections::Account.all[0]
    @collaborator = RestaurantCollections::Account.all[1]
    @restaurant = @owner.add_owned_restaurant(restaurant_data)
  end

  it 'HAPPY: should be able to add a collaborator to a restaurant' do
    auth = authorization(@owner_data)

    RestaurantCollections::AddCollaborator.call(
      auth: auth,
      restaurant: @restaurant,
      collab_email: @collaborator.email
    )

    _(@collaborator.restaurants.count).must_equal 1
    _(@collaborator.restaurants.first).must_equal @restaurant
  end

  it 'BAD: should not add owner as a collaborator' do
    auth = RestaurantCollections::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )

    _(proc {
      RestaurantCollections::AddCollaborator.call(
        auth: auth,
        restaurant: @restaurant,
        collab_email: @owner.email
      )
    }).must_raise RestaurantCollections::AddCollaborator::ForbiddenError
  end
end
