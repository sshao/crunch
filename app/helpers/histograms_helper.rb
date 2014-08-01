module HistogramsHelper
  def tumblr_url(histogram)
    "http://#{histogram.username}.tumblr.com"
  end
end
