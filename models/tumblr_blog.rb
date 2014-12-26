require "tumblr_client"

class TumblrBlog
  attr_reader :url, :response_code

  def initialize(username)
    @client ||= Tumblr::Client.new
    @url = url_for(username)
  end

  def posts(offset)
    @latest_response = @client.posts(url, type: "photo", limit: PULL_LIMIT,
                                     offset: offset, before_id: @latest_id)
    @latest_id = @latest_response["posts"].last["id"]
    @latest_response
  end

  def exists?
    info_response = @client.blog_info(url)
    @response_code = info_response["status"]
    return @response_code.nil?
  end

  def responded?
    @response_code = @latest_response["status"]
    @response_code.nil?
  end

  private
  def url_for(username)
    "#{username}.tumblr.com"
  end
end
