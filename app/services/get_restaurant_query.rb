# frozen_string_literal: true

module RestaurantCollections
    # Add a collaborator to another owner's existing restaurant
    class GetRestaurantQuery
      # Error for owner cannot be collaborator
      class ForbiddenError < StandardError
        def message
          'You are not allowed to access that restaurant'
        end
      end
  
      # Error for cannot find a restaurant
      class NotFoundError < StandardError
        def message
          'We could not find that restaurant'
        end
      end
  
      def self.call(auth:, restaurant:)
        raise NotFoundError unless restaurant
  
        policy = RestaurantPolicy.new(auth[:account], restaurant, auth[:scope])
        raise ForbiddenError unless policy.can_view?
  
        restaurant.full_details.merge(policies: policy.summary)
      end
    end
  end