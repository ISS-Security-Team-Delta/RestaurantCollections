# frozen_string_literal: true

# Policy to determine if account can view a meal
class MealPolicy
    def initialize(account, meal, auth_scope = nil)
      @account = account
      @meal = meal
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
      @auth_scope ? @auth_scope.can_read?('meals') : false
    end
  
    def can_write?
      @auth_scope ? @auth_scope.can_write?('meals') : false
    end
  
    def account_owns_restaurant?
      @meal.restaurant.owner == @account
    end
  
    def account_collaborates_on_restaurant?
      @meal.restaurant.collaborators.include?(@account)
    end
  end
  