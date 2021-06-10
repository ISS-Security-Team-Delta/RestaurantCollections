# frozen_string_literal: true

module RestaurantCollections
    # Policy to determine if account can view a restaurant
    class RestaurantPolicy
      # Scope of restaurant policies
      class AccountScope
        def initialize(current_account, target_account = nil)
          target_account ||= current_account
          @full_scope = all_restaurants(target_account)
          @current_account = current_account
          @target_account = target_account
        end
  
        def viewable
          if @current_account == @target_account
            @full_scope
          else
            @full_scope.select do |rest|
              includes_collaborator?(rest, @current_account)
            end
          end
        end
  
        private
  
        def all_restaurants(account)
          account.owned_restaurants + account.collaborations
        end
  
        def includes_collaborator?(restaurant, account)
          restaurant.collaborators.include? account
        end
      end
    end
  end