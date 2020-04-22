# frozen_string_literal: true

source("https://rubygems.org")
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

# Dummy app
gem "rails", "~> 6.0"
gem "sqlite3"

# Use Puma as the app server
gem "puma"

gem "listen", ">= 3.0.5", "< 3.2"
# Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
gem "web-console", group: :development
# Call "byebug" anywhere in the code to stop execution and get a debugger console
gem "byebug", group: %i[development test]

# To support ES6
gem "sprockets", "~> 4.0.0"
# Support ES6
gem "babel-transpiler"
# Use SCSS for stylesheets
gem "sassc-rails"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"

gem "cocoon"
gem "form_core"

gem "acts_as_list"
gem "timeliness-i18n"
gem "validates_timeliness", "~> 5.0.0.beta1"

gem "bulma-rails"
gem "jquery-rails"
gem "selectize-rails"
gem "turbolinks", "~> 5"

gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rails"
