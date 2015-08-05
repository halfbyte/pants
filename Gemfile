source 'https://rubygems.org'

# Make sure we're running on Ruby 2.1
# ruby '2.1.1'

# Core
gem 'rails', '4.1.12'
gem 'pg'
gem 'quiet_assets'
gem 'passenger'
gem 'rack-cache', :require => 'rack/cache'
gem 'timers'
gem 'exception_notification'
gem 'lograge'

# .env configuration loading
gem 'dotenv'
gem 'dotenv-rails'
# gem 'dotenv-deployment'

# Frontend
gem 'sass-rails', '~> 5.0.1'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'slim-rails'
gem 'compass-rails', '~> 2.0.4'
gem 'simple_form'
gem 'slodown', github: 'hmans/slodown', branch: 'master'
gem 'font-awesome-rails'
gem 'kaminari'
gem 'microformats2'

# Binary asset handling
gem 'dragonfly'
gem 'dragonfly-s3_data_store'

# Authorization/Authentication
gem 'cancancan'
gem 'bcrypt', '~> 3.1.7'

# API
gem 'jbuilder', '~> 2.0'

# HTTP interactions
gem 'httparty'
gem 'webmention', github: 'indieweb/mention-client-ruby'

# Monitoring
# gem 'appsignal'

gem "sentry-raven", :git => "https://github.com/getsentry/raven-ruby.git"

# Development & Testing only
#
group :test, :development do
  # Spring application reloader
  gem 'spring'
  gem 'spring-commands-rspec'

  # Debugging
  gem 'pry-rails'
  gem 'awesome_print'

  # RSpec & friends
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ffaker'
end

# Development only.
group :development do
  # Capistrano
  # Nicer error messages
  gem 'better_errors'
  gem 'binding_of_caller'

  # Log cleanup
end

# Testing only.
#
group :test do
  gem 'webmock'
end

# Production only
#
group :production do
  # .env loading for production
  gem 'dotenv-deployment'
  gem 'rails_12factor'
end

# Gems that should be installed, but will not be loaded automatically.
#
group :tools do
  gem 'invoker'
  gem 'terminal-notifier'

  # Capistrano
  gem 'capistrano-rails'
#  gem 'capistrano-chruby'
  gem 'capistrano-bundler'
  # gem 'capistrano/rvm'
  # gem 'rvm1-capistrano3'
end
