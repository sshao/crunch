require "bundler"
Bundler.require

# disable Rack::Lint in dev environment (rack#106)
# faye is incompatible with Rack::Lint (faye#199)
configure :development do
  module Rack
    class Lint
      def call(env = nil)
        @app.call(env)
      end
    end
  end
end

configure :production do
  uri = URI.parse(ENV["REDISCLOUD_URL"])

  config.gem "redis-store", :lib => "redis-store"
  require "redis-store"
  config.cache_store = :redis_store, { host: uri.host, port: uri.port, password: uri.password }
end

require_relative "app"
run CrunchApp
