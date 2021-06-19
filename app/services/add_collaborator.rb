# frozen_string_literal: true

module RestaurantCollections
  # Add a collaborator to another owner's existing restaurant
  class AddCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as collaborator'
      end
    end

    def self.call(auth:, restaurant:, collab_email:)
      invitee = Account.first(email: collab_email)
      policy = CollaborationRequestPolicy.new(
        restaurant, auth[:account], invitee, auth[:scope]
      )
      raise ForbiddenError unless policy.can_invite?

      restaurant.add_collaborator(invitee)
      invitee
    end
  end
end
