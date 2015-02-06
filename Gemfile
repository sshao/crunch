source 'https://rubygems.org'

# see https://github.com/rubinius/rubinius/issues/2810 if engine_version issues arise
ruby "2.1.5"

gem 'sinatra', '1.4.5', require: 'sinatra/base'
gem 'sinatra-param', '1.2.2'
gem 'sinatra-assetpack', '0.3.3'
gem 'rack-flash3', require: 'rack-flash'
gem "uglifier", '2.6.0'
gem "faye-websocket", '0.9.2'
gem "puma", '2.10.2'
gem 'redis-sinatra', '1.4.0'

gem "sass", "~> 3.3.0"
gem "compass", "~> 1.0"
gem 'haml'
gem "coffee-script"

gem 'tumblr_client', '0.8.5'
gem 'mini_magick', '4.0.3'
gem 'color', '~> 1.7'

gem 'rails_12factor', '0.0.3', group: :production

gem "pry", group: :development

group :test do
  gem 'fakeredis', '~> 0.5.0'
  gem 'rack-test', '~> 0.6.2'
  gem 'factory_girl', '~> 4.5.0'
  gem 'rspec', '~> 3.0.0'
  gem 'webmock', '~> 1.20.4'
end
