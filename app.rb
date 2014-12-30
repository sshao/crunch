require_relative "models/histogram"

class CrunchApp < Sinatra::Base
  enable :sessions
  set :session_secret, ENV["SESSION_SECRET"]

  register Sinatra::Cache

  PULL_LIMIT = 10

  helpers do
    def tumblr_url(histogram)
      "http://#{histogram.username}.tumblr.com"
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
        es.send(settings.cache.read(session[:key]))
      end

      es.on :close do |event|
        EM.cancel_timer(loop)
        es = nil
      end
    end
  end

  def set(arg)
    settings.cache.write(session[:key], arg)
  end

  # this is pretty horrible but i'm not sure how else to do this
  # can Histogram access the redis instance? should it?
  def work(username)
    histogram = Histogram.new(username)
    histogram.update_histogram

    new_hists = histogram.posts.map.with_index do |post, index|
      p = histogram.send(:process, post)
      set(index)
      p
    end

    set("")

    orig_hist = histogram.histogram
    histogram.histogram = histogram.send(:crunch, [orig_hist].concat(new_hists))

    histogram
  end

  post "/create" do
    begin
      histogram = Histogram.new(params[:histogram][:username])
      # FIXME error checking on whether `username` exists, etc
      redirect to("/show?username=#{histogram.username}")
    rescue
      # FIXME print errors
      redirect to("/")
    end
  end

  get "/show" do
    @histogram = work(params[:username])
    haml :"histograms/show.html"
  end
end
