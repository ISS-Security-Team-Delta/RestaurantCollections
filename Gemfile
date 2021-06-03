# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>5.3.1'
gem 'roda', '~>3'

# Configuration
gem 'figaro', '~>1'
gem 'rake', '~>13'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7'

# Database
gem 'hirb', '~>0'
gem 'sequel', '~>5'

group :production do
  gem 'pg'
end

# Sendgrid
gem 'sendgrid-ruby'

# External Services
gem 'http'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

# Debugging
gem 'pry' # necessary for rake console
gem 'rack-test'

# Development
group :development do
  gem 'rerun'
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end
