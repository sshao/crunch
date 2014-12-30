require_relative "tumblr_blog"

module Crunch
  COLOR_DIFF_THRESHOLD = 13

  def crunch(colors)
    crunch_helper(array_to_hash(colors))
  end

  def crunch_helper(colors)
    return colors if colors.nil? || colors.size <= 1

    target_color = colors.keys.first
    grouped, remainder = group_by_color(target_color, colors)

    merge_hashes(crunch_hash(grouped), crunch_helper(remainder))
  end

  def array_to_hash(array)
    return array if array.class == Hash
    array.reduce({}) { |sum, cur| merge_hashes(sum, cur) }
  end

  def group_by_color(target, colors)
    combined = colors.group_by { |color, _| color_diff(target, color) < COLOR_DIFF_THRESHOLD }

    remainder = Hash[combined[false]] unless combined[false].nil?
    grouped = Hash[combined[true]]
    return grouped, remainder
  end

  def crunch_hash(hash)
    { most_frequent_color(hash) => hash.values.inject { |sum, element| sum + element } }
  end

  def most_frequent_color(colors)
    colors.max_by { |_, freq| freq }.first
  end

  def merge_hashes(hash1, hash2)
    return hash1 if hash2.nil?
    return hash2 if hash1.nil?

    hash1.update(hash2) { |_, v1, v2| v1 + v2 }
  end

  def color_diff(color1, color2)
    rgb_color1 = ::Color::RGB.from_html(color1)
    rgb_color2 = ::Color::RGB.from_html(color2)

    # Color::RGB#delta_e94 is an instance method, hence
    # calling it thru rgb_color1
    # defined: http://bit.ly/1puM0uD
    rgb_color1.delta_e94(rgb_color1.to_lab, rgb_color2.to_lab)
  end
end

class Histogram
  include Crunch

  attr_accessor :username, :offset, :histogram

  alias :data_size :offset
  alias :data_size= :offset=

  QUANTIZE_SIZE = 5

  def initialize(username)
    raise ArgumentError, "Username is required" if username.nil? || username.empty?
    @username = username
    @histogram = {}
    @offset = 0
    @tumblr = TumblrBlog.new(username)
    raise "Could not connect to #{username}.tumblr.com" unless connected?
    update_histogram
  end

  def update_histogram
    response = @tumblr.posts(offset)

    return false if !responded?

    @offset += response["posts"].size
    generate_histogram(response["posts"])
  end

  private
  def responded?
    return true if @tumblr.responded?
    #errors.add(:username, "there was a problem connecting to #{username}@tumblr, \
               #received status code #{@tumblr.response_code}")
    false
  end

  def connected?
    return true if @tumblr.exists?
    #errors.add(:username, "could not connect to #{username}@tumblr, \
               #received status code #{@tumblr.response_code}")
    false
  end

  def generate_histogram(posts)
    new_hists = posts.map { |post| process(post) }
    @histogram = crunch([@histogram].concat new_hists)
  end

  def process(post)
    image = open_image(photo_url(post))

    # skip if there was a problem opening the image
    return if image.nil?

    hist = quantized_histogram(image)

    image.destroy!

    hist
  end

  def quantized_histogram(image)
    quantized = image.quantize(QUANTIZE_SIZE, Magick::RGBColorspace)
    histo = quantized.color_histogram
    histo = Hash[histo.map { |color, freq| [hex_color(color), freq] }]
  end

  def hex_color(color)
    color.to_color(Magick::AllCompliance, false, 8, true)
  end

  def photo_url(post)
    # FIXME photosets?
    first_photo = post["photos"][0]
    photo = standard_photo(first_photo) || original_photo(first_photo)
    photo["url"]
  end

  def standard_photo(photo_data)
    photo_data["alt_sizes"].find { |photo| photo["width"] <= 500 }
  end

  def original_photo(photo_data)
    photo_data["original_size"]
  end

  def open_image(url)
    Magick::ImageList.new(url).cur_image
  rescue Magick::ImageMagickError => e
    logger.error e.inspect
    return nil
  end
end

