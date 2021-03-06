require_relative '../helpers'

describe "HistogramsController" do
  RSpec.configure do |c|
    c.include Helpers
  end

  describe "POST #create" do
    context "with bad tumblr response" do
      before(:each) do
        stub_info_request(username)
        stub_photo_request(username)
      end

      let(:username) { "unresponsive" }
      let(:bad_tumblr) { FactoryGirl.attributes_for(:tumblr_blog, username: username) }

      it "redirects to the index page" do
        post :create, tumblr_blog: bad_tumblr
        expect(last_response).to be_redirect
        expect(last_response.location).to include("show")

        follow_redirect!

        expect(last_response).to be_redirect
        expected = last_request.base_url.sub(/(\/)+$/,'')
        actual = last_response.location.sub(/(\/)+$/,'')

        expect(actual).to eq(expected)
      end
    end

    context "with valid attributes" do
      let(:username) { FactoryGirl.attributes_for(:tumblr_blog)[:username] }
      let(:new_blog) { FactoryGirl.attributes_for(:tumblr_blog) }

      before(:each) do
        stub_info_request(username)
        stub_photo_request(username)
      end

      it "creates and redirects to the new histogram" do
        post :create, tumblr_blog: new_blog
        expect(last_response).to be_redirect
        expect(last_response.location).to include("show")
        follow_redirect!
        expect(last_response.body).to include(new_blog[:username])
        expect(last_response.body).to include("Sample size: #{Helpers::TEST_PULL_LIMIT} posts")
      end
    end

    context "with invalid attributes" do
      let(:username) { FactoryGirl.attributes_for(:invalid_tumblr_blog)[:username] }
      let(:bad_tumblr) { FactoryGirl.attributes_for(:invalid_tumblr_blog) }

      before(:each) do
        stub_info_request_undefined_user(bad_tumblr[:username])
      end

      it "redirects to the index page" do
        post :create, tumblr_blog: bad_tumblr
        expect(last_response).to be_redirect
        expected = last_request.base_url.sub(/(\/)+$/,'')
        actual = last_response.location.sub(/(\/)+$/,'')
        expect(actual).to eq(expected)
      end
    end
  end
end

