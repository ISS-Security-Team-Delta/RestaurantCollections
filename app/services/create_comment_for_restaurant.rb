# frozen_string_literal: true

module RestaurantCollections
  # Create new configuration for a restaurant
  class CreateCommentForRestaurant
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more comments'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a comment with those attributes'
      end
    end

    def self.call(auth:, restaurant:, comment_data:)
      policy = RestaurantPolicy.new(auth[:account], restaurant, auth[:scope])
      raise ForbiddenError unless policy.can_add_comments?

      restaurant.add_comment(comment_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
