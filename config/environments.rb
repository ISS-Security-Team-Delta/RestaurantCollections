# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'

module RestaurantCollections
  # Configuration for the API
  class Api < Roda
    plugin :environments

    Figaro.application = Figaro::Application.new(
      environment: environment,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load

    # Make the enviroment variables accessible to other classes
    def self.config
      Figaro.env
    end

    # Connect to the right DB
    DB = Sequel.connect(config.DATABASE_URL)

    # Make the database accessible to other classes
    def self.db
      DB
    end

    # Development console (like irb) for dev and test ENV
    configure :development, :test do
      require 'pry'
    end
  end
end
