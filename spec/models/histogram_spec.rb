require_relative '../helpers'

describe Histogram do
  RSpec.configure do |c|
    c.include Helpers
  end

  describe "#new" do
    context "with invalid parameters" do
      it "is invalid without a username" do
        username = nil
        stub_info_request_undefined_user(username)

        expect(FactoryGirl.build(:histogram, username: username).errors).to_not be_empty

        expect(FactoryGirl.build(:histogram, username: "").errors).to_not be_empty
        expect(FactoryGirl.build(:histogram, username: " ").errors).to_not be_empty
      end

      it "is invalid when the username contains invalid characters" do
        username = "test username"
        expect(FactoryGirl.build(:histogram, username: username).errors).to_not be_empty

        username = "test/username"
        expect(FactoryGirl.build(:histogram, username: username).errors).to_not be_empty

        username = "tést"
        expect(FactoryGirl.build(:histogram, username: username).errors).to_not be_empty
      end

      it "is invalid when there is no tumblr associated with its username" do
        username = FactoryGirl.attributes_for(:invalid_histogram)[:username]
        stub_info_request_undefined_user(username)

        expect(FactoryGirl.build(:invalid_histogram).errors).to_not be_empty
      end
    end

    context "with valid parameters" do
      before :each do
        @username = FactoryGirl.attributes_for(:histogram)[:username]
        stub_info_request(@username)
        stub_photo_request(@username)
      end

      it "assigns the correct username" do
        hist = FactoryGirl.build(:histogram)

        expect(hist.errors).to be_empty
        expect(hist.username).to eq @username
      end
    end
  end

  describe "#update_histogram" do
    let(:username) { FactoryGirl.attributes_for(:histogram)[:username] }
    let(:histogram) { FactoryGirl.build(:histogram, username: username) }

    before :each do
      stub_info_request(username)
      stub_photo_request(username)
    end

    it "pulls #{Helpers::TEST_PULL_LIMIT} photo posts" do
      histogram.update_histogram
      expect(histogram.posts.size).to be Helpers::TEST_PULL_LIMIT
    end

    it "assigns correct offset (data sample) size" do
      histogram.update_histogram
      expect(histogram.offset).to be Helpers::TEST_PULL_LIMIT
      expect(histogram.data_size).to be Helpers::TEST_PULL_LIMIT
    end
  end

  describe "#crunch (module method)" do
    include Crunch

    it "crunches an array of hashes together" do
      data1 = { "#FFFFFF" => 10 }
      data2 = { "#FFFFFE" => 20 }
      data3 = { "#FFFFFD" => 5 }
      data_array = [data1, data2, data3]
      expected = { "#FFFFFE" => 35 }

      expect(crunch(data_array)).to eq expected
    end

    it "combines two similar colors together" do
      data = { "#FFFFFF" => 10, "#FFFFFE" => 20 }
      expected = { "#FFFFFE" => 30 }

      expect(crunch(data)).to eq expected
    end

    it "combines many similar colors together" do
      data = { "#FFFFFF" => 10, "#fa2b18" => 4, "#FFFFFE" => 20, "#f82126" => 8,
        "#f31c21" => 10, "#bbb4b8" => 1, "#c3bbc0" => 2, "#f22328" => 5}
      expected = { "#FFFFFE" => 30, "#f31c21" => 27, "#c3bbc0" => 3 }

      expect(crunch(data)).to eq expected
    end
  end
end
