# frozen_string_literal: true

module RestaurantCollections
  # Add a collaborator to another owner's existing project
  class AddCollaboratorToRestaurant
    def self.call(email:, restaurant_id:)
      collaborator = Account.first(email: email)
      restaurant = Restaurant.first(id: restaurant_id)
      return false if restaurant.owner.id == collaborator.id

      restaurant.add_collaborator
      collaborator
    end
  end
end
