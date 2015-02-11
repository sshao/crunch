require "bundler"
Bundler.require

require_relative "models/histogram"
require_relative "models/crunch"

$redis = Redis.new

class SinatraWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(username)
    tumblr = TumblrBlog.new(username)
    tumblr.fetch_posts

    if !tumblr.errors.empty?
      flash[:alert] = tumblr.errors
      redirect to("/")
    end

    new_hists = tumblr.photos.map.with_index do |photo, index|
      hist = Histogram.new(photo)
      percentage = (((index.to_f) / tumblr.photos.size.to_f) * 100.0).to_i
      at percentage, username
      hist
    end

    histogram = Crunch.send(:crunch, new_hists.map(&:histogram))

    $redis.set username, histogram.to_json
    at 100, username
  end
end

class CrunchApp < Sinatra::Base
  enable :sessions
  set :session_secret, ENV["SESSION_SECRET"]

  use Rack::Flash

  # FIXME figure out how to configure in config.ru instead
  uri = ENV["REDISCLOUD_URL"] || nil
  self.set :cache, Sinatra::Cache::RedisStore.new(uri)

  PULL_LIMIT = 20

  helpers do
    def tumblr_url(username)
      "http://#{username}.tumblr.com"
    end
  end

  register Sinatra::AssetPack

  assets do
    serve "/js", from: "js"
    serve "/css", from: "css"
    serve "/bower_components", from: "bower_components"

    css :app, [
      "/css/app.css"
    ]

    js :modernizr, [
      "/bower_components/modernizr/modernizr.js"
    ]

    js :libs, [
      "/bower_components/jquery/dist/jquery.js",
      "/bower_components/foundation/js/foundation.js"
    ]

    js :application, [
      "/js/app.js",
    ]

    js :eventsource, [
      "/js/eventsource.js"
    ]

    js :histogram, [
      "/js/histogram.js"
    ]

    css_compression :simple
    js_compression :uglify
  end

  Tumblr.configure do |config|
    config.consumer_key = ENV["OAUTH_CONSUMER"]
  end

  before do
    session[:key] ||= SecureRandom.urlsafe_base64
  end

  get "/" do
    haml :index
  end

  get "/stream" do
    if Faye::EventSource.eventsource?(env)
      es = Faye::EventSource.new(env)

      # FIXME close when done with a request?
      loop = EM.add_periodic_timer(1) do
        begin
          job_id = settings.cache.read(:job_id)
          if job_id
            status = Sidekiq::Status::at job_id
            username = Sidekiq::Status::message job_id
            es.send({username: username, status: status}.to_json)
          end
        rescue => e
          STDERR.puts e.message
        end
      end

      es.on :close do |event|
        EM.cancel_timer(loop)
        es = nil
      end
    end
  end

  post "/create" do
    tumblr = TumblrBlog.new(params[:tumblr_blog][:username])

    if tumblr.errors.empty?
      job_id = SinatraWorker.perform_async tumblr.username
      settings.cache.write(:job_id, job_id)
    else
      flash[:alert] = tumblr.errors
      redirect to("/")
    end
  end

  get "/show" do
    @tumblr = TumblrBlog.new(params[:username])
    hist = JSON.parse($redis.get(params[:username])) if $redis.exists(params[:username])
    @histogram = hist || {}
    settings.cache.write(:job_id, nil)
    haml :"histograms/show.html"
  end
end
