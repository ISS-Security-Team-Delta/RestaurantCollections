# frozen_string_literal: true

module RestaurantCollections
  # Service object to create a new project for an owner
  class CreateRestaurantForOwner
    def self.call(owner_id:, restaurant_data:)
      Account.find(id: owner_id)
             .add_owned_restaurant(restaurant_data)
    end
  end
end
