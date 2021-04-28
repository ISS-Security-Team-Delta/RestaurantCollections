# frozen_string_literal: true

require 'rake/testtask'

task :default => :spec

# Create custom tasks

# Use predefined tasks

# Define task dependencies

# Print ENV
task :print_env do
    puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

# Run application console (pry)

# For Migrations
namespace :db do
  require_relative 'config/environments'
  require 'sequel'

  Sequel.extension :migration
  app = RestaurantCollections::Api

  desc 'Run migrations'
  task :migrate => :print_env do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(app.DB, 'app/db/migrations')
  end

  desc 'Delete database'
  task :delete do
    app.DB[:restaurants].delete
    app.DB[:meals].delete
    app.DB[:comments].delete
  end

  desc 'Delete dev or test database file'
  task :drop do
    if app.enviroment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "app/db/store/#{RestaurantCollections::Api.enviroment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end
end
