class Histogram < ActiveRecord::Base
  serialize :histogram, Hash
  validates :username, presence: true, uniqueness: true
  validate  :username_exists
  before_create :update_histogram

  def username_exists
    client = Tumblr::Client.new
    response = client.blog_info("#{username}.tumblr.com")
    if response["status"] == 404
      errors.add(:username, "not found")
    end
  end

  def update_histogram 
    client = Tumblr::Client.new
    response = client.posts("#{username}.tumblr.com", :type => "photo", :limit => PULL_LIMIT, :offset => offset)
    if response["status"].nil?
      self.offset += response["posts"].size
      generate_histogram(response["posts"])
    else
      errors.add(:username, "there was a problem connecting to #{username}, received status code #{response["status"]}")
      return false
    end
  end

  def print_and_flush(str)
    print str
    $stdout.flush
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

    self.histogram = crunch(full_histogram)
  end

  def photo_url(post)
    # FIXME photosets?
    first_photo = post["photos"][0]
    photo_500px = first_photo["alt_sizes"].find{ |photo| photo["width"] == 500 } || first_photo["original_size"]
    photo_500px["url"]
  end

  def open_image(url)
    Magick::ImageList.new(url).cur_image
  rescue Magick::ImageMagickError => e
    logger.error e.inspect
    return nil
  end

  def crunch(colors)
    new_hash = {}
    colors.each_with_index do |hash, index|
      color = hash[0]
      value = hash[1].to_i

      if index == 0
        new_hash[color] = value
      else
        
        found = false
        new_hash.each do |existing_color, existing_value|
          if color_diff(color, existing_color) < 7
            new_hash[existing_color] += value
            found = true
            break
          end
        end

        new_hash[color] = value if !found
      end
    end     
    new_hash
  end
  
  def color_diff(color1, color2)
    rgb_color1 = ::Color::RGB.from_html(color1)
    rgb_color2 = ::Color::RGB.from_html(color2)

    rgb_color1.delta_e94(rgb_color1.to_lab, rgb_color2.to_lab)
  end
end
