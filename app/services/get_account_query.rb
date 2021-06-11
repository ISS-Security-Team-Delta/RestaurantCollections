# frozen_string_literal: true

module RestaurantCollections
    # Add a collaborator to another owner's existing restaurant
    class GetAccountQuery
      # Error if requesting to see forbidden account
      class ForbiddenError < StandardError
        def message
          'You are not allowed to access that restaurant'
        end
      end
  
      def self.call(requestor:, username:)
        account = Account.first(username: username)
  
        policy = AccountPolicy.new(requestor, account)
        policy.can_view? ? account : raise(ForbiddenError)
      end
    end
  end