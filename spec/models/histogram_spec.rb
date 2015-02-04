require_relative '../helpers'

describe Histogram do
  RSpec.configure do |c|
    c.include Helpers
  end

  describe "#new" do
    # TODO test URLs, as is done in the actual app
    let(:image_path) { File.join(fixture_path, "images/yhtss.gif") }
    let(:transparent_img) { File.join(fixture_path, "images/transparent.png") }

    # TODO what if an image has < 5 colors?
    it "creates a histogram of 5 colors from an image" do
      # FIXME use factories
      hist = Histogram.new(image_path)

      expect(hist.histogram.keys.size).to be 5

      hist.histogram.each do |color, frequency|
        expect { Color::RGB.from_html(color) }.to_not raise_error
        expect(frequency).to be_a Fixnum
      end
    end

    it "creates a histogram of 5 colors from a transparent image" do
      hist = Histogram.new(image_path)

      expect(hist.histogram.keys.size).to be 5

      hist.histogram.each do |color, frequency|
        expect { Color::RGB.from_html(color) }.to_not raise_error
        expect(frequency).to be_a Fixnum
      end
    end
  end
end
