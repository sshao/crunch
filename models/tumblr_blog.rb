class TumblrBlog
  # FIXME what am i doing with response_code as a reader?
  # FIXME if i have 'photos', do i need 'posts'
  attr_reader :posts, :photos, :username, :url, :response_code, :errors
  attr_accessor :offset

  alias :data_size :offset
  alias :data_size= :offset=

  def initialize(username)
    @errors = []
    @posts = []
    @username = username
    return if !valid_username?(username)

    @client ||= Tumblr::Client.new
    @url = url_for(username)

    errors << "Could not connect to <b>#{username}</b>.tumblr.com</b>" unless exists?

    @offset = 0
  end

  def fetch_posts
    @latest_response = @client.posts(url,
                                     type: "photo",
                                     limit: CrunchApp::PULL_LIMIT,
                                     offset: offset,
                                     before_id: @latest_id)

    # FIXME should probably be an error
    return false if !responded?

    @offset += @latest_response["posts"].size
    @latest_id = @latest_response["posts"].last["id"] if @latest_response["posts"].last

    @posts = @latest_response["posts"]
    @photos = @posts.map { |post| photo_url(post) }
  end

  private
  def exists?
    info_response = @client.blog_info(url)
    # tumblr_client strips out the status response if the status is 201 | 200.
    # https://github.com/tumblr/tumblr_client/blob/87f4488/lib/tumblr/request.rb#L43
    @response_code = info_response["status"]
    @response_code.nil?
  end

  def responded?
    # FIXME a blog can respond with a bad status code
    @response_code.nil?
  end

  def valid_username?(username)
    if username.nil? || username.empty? || username.strip.empty?
      errors << "Username cannot be blank"
      return false
    end

    if !username.ascii_only? || !(username =~ /^[a-zA-Z0-9\-_]+$/)
      errors << "Username <b>#{username}</b> is invalid"
      return false
    end

    true
  end

  def url_for(username)
    "#{username}.tumblr.com"
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
end
