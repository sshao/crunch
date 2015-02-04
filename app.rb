require_relative "models/histogram"
require_relative "models/crunch"

class CrunchApp < Sinatra::Base
  enable :sessions
  set :session_secret, ENV["SESSION_SECRET"]

  use Rack::Flash

  # FIXME wtf? couldn't figure out how to configure outside
  # of this. this is horrible.
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

      loop = EM.add_periodic_timer(1) do
        begin
          es.send(settings.cache.read(session[:key], raw: true))
        rescue => e
          # FIXME actually send error to client-side eventsource
          puts e.message
        end
      end

      es.on :close do |event|
        EM.cancel_timer(loop)
        es = nil
      end
    end
  end

  # this is pretty horrible but i'm not sure how else to do this
  # can Histogram access the redis instance? should it?
  def work(tumblr)
    settings.cache.delete(session[:key]) if settings.cache.exist?(session[:key])

    # FIXME any way to avoid creating the tumblr object again?
    tumblr.fetch_posts

    new_hists = tumblr.photos.map.with_index do |photo, index|
      hist = Histogram.new(photo)
      settings.cache.increment(session[:key])
      hist
    end

    settings.cache.delete(session[:key]) if settings.cache.exist?(session[:key])

    histogram = Crunch.send(:crunch, new_hists.map(&:histogram))

    histogram
  end

  post "/create" do
    tumblr = TumblrBlog.new(params[:tumblr_blog][:username])

    if tumblr.errors.empty?
      redirect to("/show?username=#{tumblr.username}")
    else
      flash[:alert] = tumblr.errors
      redirect to("/")
    end
  end

  get "/show" do
    @tumblr = TumblrBlog.new(params[:username])
    @histogram = work(@tumblr)
    haml :"histograms/show.html"
  end
end
