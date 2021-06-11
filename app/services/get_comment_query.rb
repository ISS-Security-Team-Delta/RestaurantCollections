# frozen_string_literal: true

module RestaurantCollections
    # Add a collaborator to another owner's existing restaurant
    class GetCommentQuery
      # Error for owner cannot be collaborator
      class ForbiddenError < StandardError
        def message
          'You are not allowed to access that document'
        end
      end
  
      # Error for cannot find a restaurant
      class NotFoundError < StandardError
        def message
          'We could not find that comment'
        end
      end
  
      # Comment for given requestor account
      def self.call(requestor:, comment:)
        raise NotFoundError unless comment
  
        policy = CommentPolicy.new(requestor, comment)
        raise ForbiddenError unless policy.can_view?
  
        comment
      end
    end
  end