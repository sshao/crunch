require_relative "models/histogram"

class CrunchApp < Sinatra::Base
  PULL_LIMIT = 10

  helpers do
    def tumblr_url(histogram)
      "http://#{histogram.username}.tumblr.com"
    end
  end

  register Sinatra::AssetPack

  assets do
    # Serves files from LOCALPATH in the URI path PATH.
    # serve 'PATH', :from => 'LOCALPATH'
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
      "/js/histogram.js"
    ]

    css_compression :simple
    js_compression :uglify
  end

  Tumblr.configure do |config|
    config.consumer_key = ENV["OAUTH_CONSUMER"]
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
