FactoryGirl.define do
  factory :histogram do
    username      "arrow"

    initialize_with { Histogram.new(username) }
  end

  factory :invalid_histogram, parent: :histogram do
    username    "idontexist"
  end
end

