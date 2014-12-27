require_relative '../helpers'

describe "HistogramsController" do
  RSpec.configure do |c|
    c.include Helpers
  end

  before(:each) do
    username = FactoryGirl.attributes_for(:histogram)[:username]
    stub_info_request(username)
    stub_photo_request(username)
  end

  describe "POST #create" do
    context "with valid attributes" do
      let(:new_hist) { FactoryGirl.attributes_for(:histogram) }

      it "creates and redirects to the new histogram" do
        post :create, histogram: new_hist
        expect(last_response).to be_redirect
        expect(last_response.location).to include("show")
        follow_redirect!
        expect(last_response.body).to include(new_hist[:username])
        expect(last_response.body).to include("Sample size: #{Helpers::TEST_PULL_LIMIT} posts")
      end
    end

    context "with invalid attributes" do
      let(:bad_hist) { FactoryGirl.attributes_for(:invalid_histogram) }

      before(:each) do
        stub_info_request_undefined_user(bad_hist[:username])
      end

      it "redirects to the index page" do
        post :create, histogram: bad_hist
        expect(last_response).to be_redirect
        expected = last_request.base_url.sub(/(\/)+$/,'')
        actual = last_response.location.sub(/(\/)+$/,'')
        expect(actual).to eq(expected)
      end
    end
  end
end

