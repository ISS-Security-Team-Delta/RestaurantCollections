# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'
require './app/lib/secure_db'
require 'logger'

module RestaurantCollections
  # Configuration for the API
  class Api < Roda
    plugin :environments

    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment: environment,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config() = Figaro.env

    # Logger setup
    LOGGER = Logger.new($stderr)
    def self.logger() = LOGGER

    # Database Setup
    DB = Sequel.connect(ENV.delete('DATABASE_URL'))
    def self.DB() = DB # rubocop:disable Naming/MethodName

    # Development console (like irb) for dev and test ENV
    configure :development, :test do
      require 'pry'
      logger.level = Logger::ERROR
    end
  end
end
