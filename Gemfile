source 'https://ruby.taobao.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3'

# Supported DBs
gem "mysql2", group: :mysql

gem 'thin', "~> 1.6.1"

# grape api
gem "grape", "~> 0.4.1"
gem "grape-entity", "~> 0.3.0"

# state machine
gem "state_machine", "1.2.0"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'kaminari'
gem 'turbolinks'
gem 'jquery-rails'
gem 'bootbox-rails', '~> 0.4.0'
gem 'slim'
gem 'twitter-bootstrap-rails',
    git: 'git://github.com/seyhunak/twitter-bootstrap-rails.git',
      branch: 'bootstrap3'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano', '~> 3.1'
gem 'capistrano-bundler', '~> 1.1.2'

# HTTP requests
gem "httparty"

# Background jobs
gem 'sidekiq', '~> 2.16'
gem 'sidekiq_status', '~> 1.0.7'
gem 'sinatra', :require => nil
gem 'redis', '~> 3.2.1'
gem 'capistrano-sidekiq'

# Deploy
gem 'capistrano-rails'

# Application server
gem "unicorn-rails"

# whenever
gem 'whenever', :require => false
gem 'settingslogic'

# sidekiq-lock
gem 'sidekiq-lock'

group :development, :test do
  gem "rspec-rails", '~> 3.0.0'
  gem 'factory_girl_rails'
  gem 'debugger'
  #gem 'capistrano-unicorn', require: false, github: 'inbeom/capistrano-unicorn', branch: 'capistrano3'
  gem 'capistrano3-unicorn'
end
