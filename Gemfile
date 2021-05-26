# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>5'
gem 'roda', '~>3'

# Configurationw
gem 'figaro', '~>1'
gem 'rake','~>13'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7'

# Database
gem 'hirb', '~>0'
gem 'sequel','~>5'
group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end

# Performance
gem 'rubocop-performance'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
end

# Development
gem 'pry'
gem 'rerun'
gem 'rubocop'

# Production
group :production do 
  gem 'pg'
end
