# frozen_string_literal: true

module RestaurantCollections
  # Error for invalid credentials
  class UnauthorizedError < StandardError
    def initialize(msg = nil)
      super
      @credentials = msg
    end

    def message
      "Invalid Credentials for: #{@credentials[:username]}"
    end
  end

  # Find account and check password
  class AuthenticateAccount
    def self.call(credentials)
      account = Account.first(username: credentials[:username])
      puts "Account info: #{credentials[:password]}, #{account.username}"
      unless account.password?(credentials[:password])
        raise(UnauthorizedError, credentials)
      end
      puts "GOT HERE!!!!"
      account_and_token(account)
    end
    
    def self.account_and_token(account)
    {
      type: 'authenticated_account',
      attributes: {
        account: account,
        auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
