# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Service Authentication' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting restaurants' do
      describe 'Getting list of restaurants' do
        before do
            @account_data = DATA[:accounts][0]
            account = RestaurantCollections::Account.create(@account_data)
            account.add_owned_restaurant(DATA[:restaurants][0])
            account.add_owned_restaurant(DATA[:restaurants][1])
        end
        it 'HAPPY: should get list for authorized account' do
            auth = RestaurantCollections::AuthenticateAccount.call(
                username: @account_data['username'],
                password: @account_data['password']
                )
                header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
                get 'api/v1/restaurants'
                _(last_response.status).must_equal 200
                result = JSON.parse last_response.body
                _(result['data'].count).must_equal 2
            end
            it 'BAD: should not process for unauthorized account' do
                header 'AUTHORIZATION', 'Bearer bad_token'
                get 'api/v1/restaurants'
                _(last_response.status).must_equal 403
                result = JSON.parse last_response.body
                _(result['data']).must_be_nil
            end
        end
    end 
end