FactoryGirl.define do
  factory :histogram do
    image { File.join(fixture_path, "images/yhtss.gif") }

    initialize_with { Histogram.new(image) }
  end
end

