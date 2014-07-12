require 'rails_helper'
require_relative '../helpers'

describe Histogram do
  RSpec.configure do |c|
    c.include Helpers
  end

  describe "#new" do
    it "is invalid without a username" do
      stub_info_request_undefined_user(nil)
      expect(FactoryGirl.build(:histogram, username: nil)).to_not be_valid
    end

    it "is invalid when there is no tumblr associated with its username" do
      stub_info_request_undefined_user(FactoryGirl.attributes_for(:invalid_histogram)[:username])
      expect(FactoryGirl.build(:invalid_histogram)).to_not be_valid
    end

    it "populates a histogram" do
      username = FactoryGirl.attributes_for(:histogram)[:username]
      stub_info_request(username)
      stub_photo_request(username)

      expect(FactoryGirl.create(:histogram).histogram).to_not be_empty
    end
  end

end
