require 'sinatra'
require 'sinatra/param'
require 'haml'
require 'tumblr_client'
require_relative 'models/histogram'

PULL_LIMIT = 10

def tumblr_url(histogram)
  "http://#{histogram.username}.tumblr.com"
end

Tumblr.configure do |config|
  config.consumer_key = ENV["OAUTH_CONSUMER"]
end

class CrunchApp < Sinatra::Base
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
