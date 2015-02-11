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

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

require_relative "app"
run CrunchApp
