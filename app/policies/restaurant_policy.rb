# frozen_string_literal: true

module RestaurantCollections
  # Policy to determine if an account can view a particular restaurant
  class RestaurantPolicy
    def initialize(account, restaurant, auth_scope = nil)
      @account = account
      @restaurant = restaurant
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_owns_restaurant? || account_collaborates_on_restaurant?)
    end
  
    def can_edit?
      can_write? && (account_owns_restaurant? || account_collaborates_on_restaurant?)
    end
  
    def can_delete?
      can_write? && (account_owns_restaurant? || account_collaborates_on_restaurant?)
    end
  
    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end
  
    private
  
    def can_read?
      @auth_scope ? @auth_scope.can_read?('comments') : false
    end
  
    def can_write?
      @auth_scope ? @auth_scope.can_write?('comments') : false
    end
  
    def account_owns_restaurant?
      @comment.restaurant.owner == @account
    end
  
    def account_collaborates_on_restaurant?
      @comment.restaurant.collaborators.include?(@account)
    end
end
