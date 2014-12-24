module Helpers
  TEST_PULL_LIMIT = 3
  API_URI = "api.tumblr.com/v2/blog"

  def api_uri_for(username)
    "#{API_URI}/#{username}.tumblr.com"
  end

  def photo_uri(username)
    %r{#{api_uri_for(username)}/posts/photo\?.*&limit=#{PULL_LIMIT}}
  end

  def info_uri(username)
    %r{#{api_uri_for(username)}/info}
  end

  def headers
    {'content-type' => 'application/json'}
  end

  def stub_photo_request(username)
    fp = File.join(fixture_path, "#{username}_photos_success.json")
    body = File.read(fp)

    stub_request(:get, photo_uri(username)).to_return(status: 200,
                                                      headers: headers,
                                                      body: body)
  end

  def stub_info_request(username)
    fp = File.join(fixture_path, "#{username}_info_success.json")
    body = File.read(fp)

    stub_request(:get, info_uri(username)).to_return(status: 200,
                                                     headers: headers,
                                                     body: body)
  end

  def stub_info_request_undefined_user(username)
    body = '{"meta":{"status":404,"msg":"Not Found"},"response":[]}'

    stub_request(:get, info_uri(username)).to_return(status: 404,
                                                     headers: headers,
                                                     body: body)
  end
end
