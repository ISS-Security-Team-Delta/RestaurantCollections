# frozen_string_literal: true

require 'roda'
require_relative './app'

module RestaurantCollections
  # Web controller for RestaurantCollections API
  class Api < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      # All requests in this route require signed requests
      begin
        @request_data = SignedRequest.new(Api.config).parse(request.body.read)
      rescue SignedRequest::VerificationError
        routing.halt '403', { message: 'Must sign request' }.to_json
      end

      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          VerifyRegistration.new(@request_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
          puts e.message
          routing.halt 500
        end
      end

      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          auth_account = AuthenticateAccount.call(@request_data)
          { data: auth_account }.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt '401', { message: 'Invalid credentials' }.to_json
        end
      end

      # POST /api/v1/auth/sso
      routing.post 'sso' do
        auth_account = AuthorizeSso.new.call(@request_data[:access_token])
        { data: auth_account }.to_json
      rescue StandardError => error
        puts "FAILED to validate Github account: #{error.inspect}"
        puts error.backtrace
        routing.halt 400
      end

      routing.on 'google_sso' do
     # POST /api/v1/auth/google_sso
       routing.post do
         auth_account = AuthorizeGoogleSso.new.call(@request_data[:id_token], @request_data[:aud])
         { data: auth_account }.to_json
       rescue AuthorizeGoogleSso::UnauthorizedError => e
         puts [e.class, e.message].join ': '
         routing.halt 401, { message: 'Invalid credentials' }.to_json
       rescue StandardError => e
         puts "FAILED to validate Google account: #{e.inspect}"
         puts e.backtrace
         routing.halt 400
       end
     end
      # POST api/v1/auth/resetpwd
      routing.on 'resetpwd' do
        routing.post do
          VerifyResetPassword.new(@request_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyResetPassword::InvalidResetPassword => e
          puts [e.class, e.message].join ': '
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
          puts e.message
          routing.halt 500
        end
      end
    end
  end
end
