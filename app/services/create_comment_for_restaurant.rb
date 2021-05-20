# frozen_string_literal: true

module RestaurantCollections
  # Create new configuration for a project
  class CreateCommentForRestaurant
    def self.call(restaurant_id:, comment_data:)
      Restaurant.first(id: restaurant_id)
             .add_comment(comment_data)
    end
  end
end
