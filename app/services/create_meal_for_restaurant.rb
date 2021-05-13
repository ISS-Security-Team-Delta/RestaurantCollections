# frozen_string_literal: true

module RestaurantCollections
  class CreateMealForRestaurant
    def self.call(restaurant_id:, meal_data:)
      Restaurant.first(id: restaurant_id).add_meal(meal_data)
    end
  end
end
  