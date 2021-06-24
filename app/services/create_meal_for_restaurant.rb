# frozen_string_literal: true

require './app/policies/restaurant_policy'

module RestaurantCollections
  # Create new configuration for a restaurant
  class CreateMealForRestaurant
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add meals'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a meal with those attributes'
      end
    end

    def self.call(auth:, restaurant:, meal_data:)
      policy = RestaurantPolicy.new(auth[:account], restaurant, auth[:scope])
      raise ForbiddenError unless policy.can_add_meals?

      restaurant.add_meal(meal_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
