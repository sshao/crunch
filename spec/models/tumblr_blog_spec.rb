require_relative '../helpers'

describe TumblrBlog do
  RSpec.configure do |c|
    c.include Helpers
  end

  describe "#new" do
    context "with invalid parameters" do
      it "is invalid without a username" do
        stub_info_request_undefined_user(nil)

        blank_usernames = [nil, "", " "]

        blank_usernames.each do |username|
          expect(FactoryGirl.build(:tumblr_blog, username: username).errors).to_not be_empty
        end
      end

      it "is invalid when the username contains invalid characters" do
        invalid_usernames = ["test username", "test/username", "tést"]
        invalid_usernames.each do |username|
          expect(FactoryGirl.build(:tumblr_blog, username: username).errors).to_not be_empty
        end
      end

      it "is invalid when there is no tumblr associated with its username" do
        username = FactoryGirl.attributes_for(:invalid_tumblr_blog)[:username]
        stub_info_request_undefined_user(username)

        expect(FactoryGirl.build(:invalid_tumblr_blog).errors).to_not be_empty
      end
    end

    context "with valid parameters" do
      before :each do
        @username = FactoryGirl.attributes_for(:tumblr_blog)[:username]
        stub_info_request(@username)
        stub_photo_request(@username)
      end

      it "assigns the correct username" do
        hist = FactoryGirl.build(:tumblr_blog)

        expect(hist.errors).to be_empty
        expect(hist.username).to eq @username
      end
    end
  end

  describe "#fetch_posts" do
    let(:blog) { FactoryGirl.build(:tumblr_blog, username: username) }

    before :each do
      stub_info_request(username)
      stub_photo_request(username)
    end

    context "blog has > #{Helpers::TEST_PULL_LIMIT} photo posts" do
      let(:username) { FactoryGirl.attributes_for(:tumblr_blog)[:username] }
      it "pulls #{Helpers::TEST_PULL_LIMIT} photo posts" do
        blog.fetch_posts
        expect(blog.posts.size).to be Helpers::TEST_PULL_LIMIT
      end

      it "assigns correct offset (data sample) size" do
        blog.fetch_posts
        expect(blog.offset).to be Helpers::TEST_PULL_LIMIT
        expect(blog.data_size).to be Helpers::TEST_PULL_LIMIT
      end
    end

    context "blog has < #{Helpers::TEST_PULL_LIMIT} posts" do
      let(:username) { "arrow2" }
      let(:num_posts) { 2 }

      it "pulls the correct number of photo posts" do
        blog.fetch_posts
        expect(blog.posts.size).to be num_posts
      end

      it "assigns correct offset (data sample) size" do
        blog.fetch_posts
        expect(blog.offset).to be num_posts
        expect(blog.data_size).to be num_posts
      end
    end

    context "blog has 0 photo posts" do
      let(:username) { "empty" }

      it "pulls 0 photo posts" do
        blog.fetch_posts
        expect(blog.posts.size).to be 0
      end

      it "assigns correct offset (data sample) size" do
        blog.fetch_posts
        expect(blog.offset).to be 0
        expect(blog.data_size).to be 0
      end
    end
  end

  describe "#photos" do
    let(:username) { FactoryGirl.attributes_for(:tumblr_blog)[:username] }
    let(:blog) { FactoryGirl.build(:tumblr_blog, username: username) }

    before :each do
      stub_info_request(username)
      stub_photo_request(username)
      blog.fetch_posts
    end

    it "returns an array of photo URLs" do
      blog.photos.each do |url|
        expect(url).to be_a String
        # FIXME bad and not sure if/how to test this
        expect(url).to include ".gif"
      end
    end
  end
end
