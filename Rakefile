# frozen_string_literal: true

require 'rake/testtask'

task :default => :spec

# Create custom tasks
desc 'Test API specs only'
task :api_spec do
  sh 'ruby spec/api_spec.rb'
end

# Use predefined tasks
desc 'Test all the specs'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

# Define task dependencies
desc 'Runs rubocop on tested code'
task :style => [:spec, :audit] do
  sh 'rubocop .'
end

# Print ENV
task :print_env do
    puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

# Run application console (pry)
desc 'Run application console (pry)'
task :console => :print_env do
  sh 'pry -r ./spec/test_load_all'
end
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
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "app/db/store/#{RestaurantCollections::Api.enviroment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end
end
