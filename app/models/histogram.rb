class Histogram < ActiveRecord::Base
  serialize :histogram, Hash

  validates :username, presence: true, uniqueness: true
  validate  :username_exists

  before_create :update_histogram

  alias_attribute :data_size, :offset

  QUANTIZE_SIZE = 5
  COLOR_DIFF_THRESHOLD = 13
  
  def update_histogram 
    @client ||= Tumblr::Client.new
    response = @client.posts(tumblr_url, 
                             type: "photo", 
                             limit: PULL_LIMIT, 
                             offset: offset)
    if !successful?(response)
      errors.add(:username, "there was a problem connecting to #{username}, received status code #{response["status"]}")
      return false
    end

    self.offset += response["posts"].size
    generate_histogram(response["posts"])
  end

  private
  def tumblr_url
    "#{username}.tumblr.com"
  end

  def successful?(response)
    return response["status"].nil?
  end

  def not_found?(response)
    return response["status"] == 404
  end

  def username_exists
    @client ||= Tumblr::Client.new
    response = @client.blog_info(tumblr_url)
    errors.add(:username, "not found") if not_found?(response)
  end
  
  def generate_histogram(posts)
    full_histogram = self.histogram || {}
    histograms = [full_histogram]

    posts.each do |post|
      image = open_image(photo_url(post))

      # skip if there was a problem opening the image
      return if image.nil?

      histograms.push quantized_histogram(image)
    end

    self.histogram = crunch(histograms)
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
    photo_data["alt_sizes"].find { |photo| photo["width"] == 500 }
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
    { most_frequent_color(hash) => hash.values.sum }
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

