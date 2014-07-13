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

  describe "#crunch" do
    # FIXME this is stupid and should not be required
    let(:histogram) { FactoryGirl.create(:histogram) }

    # FIXME this too obvs
    before(:each) do
      stub_info_request(FactoryGirl.attributes_for(:histogram)[:username])
      stub_photo_request(FactoryGirl.attributes_for(:histogram)[:username])
    end

    # FIXME both specs depends on hash order ...
    it "combines two similar colors together" do
      data = { "#FFFFFF" => 10, "#FFFFFE" => 20 }
      expected = { "#FFFFFF" => 30 }
      expect(histogram.crunch(data)).to eq expected
    end

    it "combines many similar colors together" do
      data = { "#FFFFFF" => 10, "#fa2b18" => 4, "#FFFFFE" => 20, "#f82126" => 8,
        "#f31c21" => 10, "#bbb4b8" => 1, "#c3bbc0" => 2, "#f22328" => 5}
      expected = { "#FFFFFF" => 30, "#fa2b18" => 27, "#bbb4b8" => 3 }
      expect(histogram.crunch(data)).to eq expected
    end
  end

end
