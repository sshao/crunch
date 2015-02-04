require_relative "tumblr_blog"

class Histogram
  attr_accessor :histogram

  def initialize(path)
    @histogram = process(path)
  end

  private
  def process(path)
    image = open_image(path)

    # skip if there was a problem opening the image
    return if image.nil?

    hist = quantized_histogram(image)

    image.destroy!

    hist
  end

  def quantized_histogram(image)
    raw = MiniMagick::Tool::Convert.new do |convert|
      convert << "#{image.path}[0]" # [0] grabs the 1st frame of any animated gifs
      convert.colors "5"
      convert.format "%c\n"
      convert.depth "8"
      convert.background "white"
      convert.alpha "remove"
      convert.alpha "off"
      convert << "histogram:info:"
    end
    Hash[*parse_raw_histogram(raw)]
  end

  def parse_raw_histogram(raw)
    raw = raw.split(' ')
    raw.select! { |x| x[-1] == ":" || x[0] == "#" } # select freqs + colors
    raw.reverse! # reverse order from [freq1, color1, ...] to [color1, freq1, ...]
    raw.map { |x| x[-1] == ":" ? x[0..-1].to_i : x } # convert freqs to ints
  end

  def open_image(url)
    MiniMagick::Image.open(url)
  rescue MiniMagick::Error => e
    logger.error e.inspect
    return nil
  end
end

