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
      can_read? && (account_is_owner? || account_is_collaborator?)
    end

    # duplication is ok!
    def can_edit?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      account_is_collaborator?
    end

    def can_add_comments?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_remove_comments?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_add_meals?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_remove_meals?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_add_collaborators?
      can_write? && account_is_owner?
    end

    def can_remove_collaborators?
      can_write? && account_is_owner?
    end

    def can_collaborate?
      !(account_is_owner? || account_is_collaborator?)
    end

    def summary # rubocop:disable Metrics/MethodLength
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_comments: can_add_comments?,
        can_delete_comments: can_remove_comments?,
        can_add_meals: can_add_meals?,
        can_delete_meals: can_remove_meals?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_collaborate: can_collaborate?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('restaurants') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('restaurants') : false
    end

    def account_is_owner?
      @restaurant.owner == @account
    end

    def account_is_collaborator?
      @restaurant.collaborators.include?(@account)
    end
  end
end