# frozen_string_literal: true

module RestaurantCollections
  # Policy to determine if an account can view a particular restaurant
  class CollaborationRequestPolicy
    def initialize(restaurant, requestor_account, target_account, auth_scope)
      @restaurant = restaurant
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = RestaurantPolicy.new(requestor_account, restaurant, auth_scope)
      @target = RestaurantPolicy.new(target_account, restaurant, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_collaborators? && @target.can_collaborate?)
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_collaborators? && target_is_collaborator?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('restaurants') : false
    end

    def target_is_collaborator?
      @restaurant.collaborators.include?(@target_account)
    end
  end
end
