class TumblrBlog
  attr_reader :url, :response_code

  def initialize(username)
    @client ||= Tumblr::Client.new
    @url = url_for(username)
  end

  def posts(offset)
    @latest_response = @client.posts(url,
                                     type: "photo",
                                     limit: CrunchApp::PULL_LIMIT,
                                     offset: offset,
                                     before_id: @latest_id)
    @latest_id = @latest_response["posts"].last["id"]
    @response_code = @latest_response["status"]
    @latest_response
  end

  def exists?
    info_response = @client.blog_info(url)
    # tumblr_client strips out the status response if the status is 201 | 200.
    # https://github.com/tumblr/tumblr_client/blob/87f4488/lib/tumblr/request.rb#L43
    info_response["status"].nil?
  end

  def responded?
    # FIXME can respond with a bad status code
    @response_code.nil?
  end

  private
  def url_for(username)
    "#{username}.tumblr.com"
  end
end
