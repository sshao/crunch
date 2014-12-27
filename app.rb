require 'sinatra'
require 'sinatra/param'
require 'sinatra/assetpack'
require 'haml'
require 'tumblr_client'
require "coffee_script"
require_relative 'models/histogram'

PULL_LIMIT = 10

def tumblr_url(histogram)
  "http://#{histogram.username}.tumblr.com"
end

Tumblr.configure do |config|
  config.consumer_key = ENV["OAUTH_CONSUMER"]
end

class CrunchApp < Sinatra::Base
  register Sinatra::AssetPack

  assets do
    serve "/js", from: 'js'
    serve '/bower_components', from: 'bower_components'

    js :modernizr, [
      '/bower_components/modernizr/modernizr.js',
    ]

    js :libs, [
      '/bower_components/jquery/dist/jquery.js',
      '/bower_components/foundation/js/foundation.js'
    ]

    js :application, [
      '/js/app.js',
      '/js/histogram.js'
    ]

    js_compression :jsmin
  end

  get "/" do
    haml :index
  end

  post "/create" do
    begin
      histogram = Histogram.new(params[:histogram][:username])
      redirect to("/show?username=#{histogram.username}")
    rescue
      redirect to("/")
    end
  end

  get "/show" do
    @histogram = Histogram.new(params[:username])
    haml :"histograms/show.html"
  end
end
