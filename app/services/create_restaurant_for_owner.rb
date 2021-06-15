# frozen_string_literal: true

module RestaurantCollections
  # Service object to create a new restaurant for an owner
  class CreateRestaurantForOwner
     # Error for owner cannot be collaborator
     class ForbiddenError < StandardError
      def message
        'You are not allowed to add more comments'
      end
    end

    def self.call(auth:, restaurant_data:)
      raise ForbiddenError unless auth[:scope].can_write?('restaurants')

      auth[:account].add_owned_restaurant(restaurant_data)
    end
  end
end
