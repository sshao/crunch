FactoryGirl.define do
  factory :histogram do
    # FIXME
    #image File.join(fixture_path, "images/yhtss.gif").to_s

    initialize_with { Histogram.new(image) }
  end
end

