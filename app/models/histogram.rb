class Histogram < ActiveRecord::Base
  serialize :histogram, Hash
  validates :username, presence: true, uniqueness: true
  validate  :username_exists
  before_create :update_histogram

  alias_attribute :data_size, :offset

  COLOR_DIFF_THRESHOLD = 13
  
  def update_histogram 
    @client ||= Tumblr::Client.new
    response = @client.posts(tumblr_url, type: "photo", limit: PULL_LIMIT, offset: offset)
    if response["status"].nil?
      self.offset += response["posts"].size

      generate_histogram(response["posts"])
      self.histogram = crunch(self.histogram)
    else
      errors.add(:username, "there was a problem connecting to #{username}, received status code #{response["status"]}")
      return false
    end
  end

  private
  def tumblr_url
    "#{username}.tumblr.com"
  end

  def username_exists
    @client ||= Tumblr::Client.new
    response = @client.blog_info(tumblr_url)
    if response["status"] == 404
      errors.add(:username, "not found")
    end
  end
  
  def generate_histogram(posts)
    full_histogram = self.histogram || {}

    posts.each do |post|
      image = open_image(photo_url(post))
      # skip if there was a problem opening the image
      return if image.nil?
      
      quantized_img = image.quantize(5, Magick::RGBColorspace)
      
      histo = quantized_img.color_histogram
      histo = Hash[histo.map { |k,v| [k.to_color(Magick::AllCompliance, false, 8, true), v] }]

      full_histogram = full_histogram.merge(histo) { |k, v1, v2| v1 + v2 }
    end

    self.histogram = full_histogram
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
    return colors if colors.nil? || colors.size <= 1

    target_color = colors.keys.first
    results = colors.group_by { |color, _| color_diff(target_color, color) < COLOR_DIFF_THRESHOLD }

    remainder = Hash[results[false]] unless results[false].nil?
    merge_hashes(crunch_hash(Hash[results[true]]), crunch(remainder))
  end

  def crunch_hash(hash)
    { hash.max_by { |_, v| v }.first => hash.map { |_, v| v }.sum }
  end

  def merge_hashes(hash1, hash2)
    return hash1 if hash2.nil?
    return hash2 if hash1.nil?

    hash1.merge(hash2) { |_, v1, v2| v1 + v2 }
  end
  
  def color_diff(color1, color2)
    rgb_color1 = ::Color::RGB.from_html(color1)
    rgb_color2 = ::Color::RGB.from_html(color2)

    rgb_color1.delta_e94(rgb_color1.to_lab, rgb_color2.to_lab)
  end
end
