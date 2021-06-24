# frozen_string_literal: true

module RestaurantCollections
    # Add a collaborator to another owner's existing restaurant
    class GetMealQuery
      # Error for owner cannot be collaborator
      class ForbiddenError < StandardError
        def message
          'You are not allowed to access that meal'
        end
      end
  
      # Error for cannot find a restaurant
      class NotFoundError < StandardError
        def message
          'We could not find that meal'
        end
      end
  
      # Comment for given requestor account
      def self.call(auth:, meal:)
        raise NotFoundError unless meal
  
        policy = MealPolicy.new(auth[:account], meal, auth[:scope])
        raise ForbiddenError unless policy.can_view?
  
        meal
      end
    end
  end