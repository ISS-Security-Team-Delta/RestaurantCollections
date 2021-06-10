# frozen_string_literal: true

module RestaurantCollections
  # Policy to determine if an account can view a particular project
  class CollaborationRequestPolicy
    def initialize(project, requestor_account, target_account)
      @restaurant = restaurant
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = RestaurantPolicy.new(requestor_account, project)
      @target = RestaurantPolicy.new(target_account, project)
    end

    def can_invite?
      @requestor.can_add_collaborators? && @target.can_collaborate?
    end

    def can_remove?
      @requestor.can_remove_collaborators? && target_is_collaborator?
    end

    private

    def target_is_collaborator?
      @restaurant.collaborators.include?(@target_account)
    end
  end
end
