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

  attr_accessor :username, :offset, :histogram, :posts, :errors

  alias :data_size :offset
  alias :data_size= :offset=

  def initialize(username)
    @errors = []

    if username.nil? || username.empty? || username.strip.empty?
      errors << "Username cannot be blank"
      return
    end

    if !valid?(username)
      errors << "Username <b>#{username}</b> is invalid"
      return
    end

    @username = username
    @histogram = {}
    @offset = 0
    @tumblr = TumblrBlog.new(username)

    errors << "Could not connect to <b>#{username}</b>.tumblr.com, received <b>#{@tumblr.response_code}</b>" unless connected?
  end

  def update_histogram
    response = @tumblr.posts(offset)
    return false if !responded?

    @posts = response["posts"]

    @offset += @posts.size
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
    false
  end

  # this may be dead code; see crunchapp#work
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
    MiniMagick::Image.open(url)
  rescue MiniMagick::Error => e
    logger.error e.inspect
    return nil
  end

  def valid?(username)
    return false if !username.ascii_only?
    return false if !(username =~ /^[a-zA-Z0-9\-_]+$/)
    true
  end
end

