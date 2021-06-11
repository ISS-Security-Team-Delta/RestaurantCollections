# frozen_string_literal: true

module RestaurantCollections
    # Add a collaborator to another owner's existing restaurant
    class RemoveCollaborator
      # Error for owner cannot be collaborator
      class ForbiddenError < StandardError
        def message
          'You are not allowed to remove that person'
        end
      end
  
      def self.call(req_username:, collab_email:, restaurant_id:)
        account = Account.first(username: req_username)
        restaurant = Restaurant.first(id: restaurant_id)
        collaborator = Account.first(email: collab_email)
  
        policy = CollaborationRequestPolicy.new(restaurant, account, collaborator)
        raise ForbiddenError unless policy.can_remove?
  
        restaurant.remove_collaborator(collaborator)
        collaborator
      end
    end
  end