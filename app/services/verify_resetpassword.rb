# frozen_string_literal: true
require 'sendgrid-ruby'

module RestaurantCollections
  ## Send email verfification email
  # params:
  #   - registration: hash with keys :username :email :verification_url
  class VerifyResetPassword
    # Error for invalid registration details
    class InvalidResetPassword < StandardError; end
    include SendGrid

    def initialize(resetpassword)
      @resetpassword = resetpassword
    end

    # rubocop:disable Layout/EmptyLineBetweenDefs
    def mail_key() = ENV['SENDGRID_API_KEY']
    # rubocop:enable Layout/EmptyLineBetweenDefs

    def call
      raise(InvalidResetPassword, 'Account does not exist') unless email_exist?
      send_email_verification
    end

    def email_exist?
      !Account.first(email: @resetpassword[:email]).nil?
    end

    def html_email
      <<~END_EMAIL
        <H2>Restaurant Collections App Password Reset</H2>
        <p>Please <a href=\"#{@resetpassword[:verification_url]}\">click here</a>
        to validate your email.
        You will be asked to reset a password to activate your account.</p>
      END_EMAIL
    end

    def text_email
      <<~END_EMAIL
        Restaurant Collections App Password Reset\n\n
        Please use the following url to validate your email:\n
        #{@resetpassword[:verification_url]}\n\n
        You will be asked to reset a password to activate your account.
      END_EMAIL
    end

    def mail_setup
      from = Email.new(email: 'restaurantcollections@gmail.com')
      to = Email.new(email: @resetpassword[:email])
      subject = 'Restaurant Collections App Password Reset'
      content = Content.new(type: 'text/html', value: html_email)
      Mail.new(from, subject, to, content)
    end

    def send_email_verification
      mail = mail_setup
      sg = SendGrid::API.new(api_key: mail_key)
      response = sg.client.mail._('send').post(request_body: mail.to_json)
    rescue StandardError => e
      puts "EMAIL ERROR: #{e.inspect}"
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
  end
end
